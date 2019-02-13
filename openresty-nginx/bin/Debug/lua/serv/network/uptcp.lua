local tbl_insert = table.insert
local setmetatable = setmetatable
local tostring = tostring
local str_sub = string.sub

local tcp = ngx.socket.tcp
local semaphore = require("ngx.semaphore")

local _M = {
    _VERSION = "0.21",
    _DESCRIPTION = "wrapper of tcp upstream"
}

-- constant
local CONNECT_TIMEOUT = 1000 -- ms
local STATE_CONNECTED = 1

--
local mt = {__index = _M}

function _M.new(self)
    return setmetatable(
        {
            --
            sock = false,
            sema_send = false,
            sema_send_buffer = false,
            --
            enable_reconnect = true,
            reconnect_delay_seconds = 30.001
        },
        mt
    )
end

local function _init_sema(self)
    -- sema
    self.state = STATE_CONNECTED
    self.sema_send = semaphore.new()
    self.sema_send_buffer = {}

    local function sema_send_handler()
        while true do
            local ok, err = self.sema_send:wait(30) -- wait for 30s
            if not ok then
                if err ~= "timeout" then
                    return nil, "sema_send_handler: failed to wait on sema: " .. err
                end
            else
                local curr_conn = self.ctx.curr_conn
                local s = curr_conn.upstream
                local packet_obj = curr_conn.packet_obj

                for _, v in ipairs(self.sema_send_buffer) do
                    packet_obj:write(s, v[1], v[2], 0)
                end
                self.sema_send_buffer = {}
            end
        end
    end

    --
    return ngx.thread.spawn(sema_send_handler)
end

local tfl = function(str)
    -- trim first letter
    return str_sub(str, 2)
end

--
function _M.send(self, msg, msgsn)
    local meta = getmetatable(msg)
    local msgname = tfl(meta._descriptor.full_name)
    local msgdata = msg:SerializeToString()

    local curr_conn = ngx.ctx.curr_conn
    local s = curr_conn.downstream
    local packet_obj = curr_conn.packet_obj
    return packet_obj:write(s, msgname, msgdata, msgsn)
end

--
function _M.post_to_sema(self, msg)
    local meta = getmetatable(msg)
    local msgname = tfl(meta._descriptor.full_name)
    local msgdata = msg:SerializeToString()
    local to_send = {msgname, msgdata}

    tbl_insert(self.sema_send_buffer, to_send)
    return self.sema_send:post(1)
end

--
function _M.set_timeout(self, timeout)
    local sock = self.sock
    if not sock then
        return nil, "not initialized"
    end

    return sock:settimeout(timeout)
end

--
function _M.connect(self, opts)
    local sock = self.sock
    if not sock then
        return nil, "not initialized"
    end

    --1s, 1s, 9999 minutes(read never timeout)
    sock:settimeouts(1000, 1000, 1000 * 60 * 9999) -- timeout for connect/send/receive

    local ok, err

    local host = opts.cfg.host
    if host then
        local port = opts.cfg.port or 8860

        ok, err = sock:connect(host, port)
    else
        local path = opts.cfg.path
        if not path then
            return nil, 'neither "host" nor "path" options are specified'
        end

        ok, err = sock:connect("unix:" .. path)
    end

    if not ok then
        return nil, "failed to connect: " .. err
    end

    _init(self)

    -- cb
    opts.connected_cb(self)
    return 1
end

--
function _M.close(self)
    local sock = self.sock
    if not sock then
        return nil, "not initialized"
    end

    self.state = nil

    return sock:close()
end

--
function _M.run(self, opts)
    --
    local function run_handler(premature, opts)
        -- do some routine job in Lua just like a cron job
        if premature then
            return
        end

        local workerid = ngx.worker.id()
        local packet_obj
        local pkt

        --
        self.curr_conn = {}

        -- reset sock
        if self.sock then
            self.sock:close()
            self.sock = false
        end

        -- new sock
        local sock, err1 = tcp()
        if not sock then
            return nil, "no socket -- workerid: " ..
                tostring(workerid) ..
                    ", cid: " ..
                        tostring(opts.cfg.id) ..
                            ", cname: " ..
                                opts.cfg.name .. ", host: " .. opts.cfg.host .. ", port: " .. tostring(opts.cfg.port)
        end
        self.sock = sock

        --
        local ok, err2 = self:connect(opts)
        if not ok then
            -- broadcast error to session
            local errmsg = Gate_pb.ErrorNo()
            errmsg.error_no = -9000
            errmsg.desc = "上行服务器故障，请重新登录"

            local client_helper = require("serv.network.client_helper")
            client_helper.broadcast_to_sema("mygate_server", errmsg)

            -- reconnect
            if self.enable_reconnect and self.reconnect_delay_seconds > 0 then
                ngx.timer.at(self.reconnect_delay_seconds, run_handler, opts)
            end
            return nil, err
        end

        if self.state ~= STATE_CONNECTED then
            return nil, "link broken -- workerid: " ..
                tostring(workerid) ..
                    ", cid: " ..
                        tostring(opts.cfg.id) ..
                            ", cname: " ..
                                opts.cfg.name .. ", host: " .. opts.cfg.host .. ", port: " .. tostring(opts.cfg.port)
        end

        self.curr_conn.upstream = sock

        --
        packet_type = opts.packet_type or 2
        if packet_type == 1 then
            packet_obj = packet1.new()
        else
            packet_obj = packet2.new()
        end
        self.curr_conn.packet_obj = packet_obj

        --
        while true do
            -- read packet
            local pkt, err = packet_obj:read(sock)
            if not pkt then
                ngx.say("failed to read packet: ", err)
                break
            end

            if opts.got_packet_cb then
                -- packet dispatcher
                opts.got_packet_cb(pkt)
            end
        end

        opts.disconnected_cb(s)
    end

    --
    ngx.timer.at(0, run_handler, opts)
end

return _M
