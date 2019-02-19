local _M = {
    _VERSION = "1.0.0.1",
    _DESCRIPTION = "wrapper of tcp upstream"
}

local tbl_insert = table.insert
local setmetatable, getmetatable = setmetatable, getmetatable
local tostring, pairs, ipairs = tostring, pairs, ipairs
local str_sub = string.sub

local ngx_worker = ngx.worker
local ngx_timer = ngx.timer
local ngx_thread = ngx.thread
local ngx_say = ngx.say
local ngx_sleep = ngx.sleep

local ngx_tcp = ngx.socket.tcp
local ngx_semaphore = require("ngx.semaphore")

-- Localize
local cwd = (...):gsub("%.[^%.]+$", "") .. "."
local packet1 = require(cwd .. "outer_packet")
local packet2 = require(cwd .. "inner_packet")
local client_helper = require(cwd .. "client_helper")

-- constant
local STATE_CONNECTED = 1
local STATE_CLOSED = 2

--
local mt = {__index = _M}

function _M.new(self, id)
    return setmetatable(
        {
            --
            id = id,
            --
            sock = false,
            sema_send = false,
            sema_send_packet_queue = false,
            --
            enable_reconnect = true,
            reconnect_delay_seconds = 1.001
        },
        mt
    )
end

--
function _M.send_raw(self, data)
    local curr_conn = self.curr_conn
    local s = curr_conn.upstream
    return s:send(data)
end

local tfl = function(str)
    -- trim first letter
    return str_sub(str, 2)
end

--
function _M.send_msg(self, msg, msgsn)
    local meta = getmetatable(msg)
    local msgname = tfl(meta._descriptor.full_name)
    local msgdata = msg:SerializeToString()

    local curr_conn = self.curr_conn
    local s = curr_conn.upstream
    local packet_obj = curr_conn.packet_obj
    return packet_obj:write(s, msgname, msgdata, msgsn)
end

--
function _M.post_to_sema(self, msg)
    local meta = getmetatable(msg)
    local msgname = tfl(meta._descriptor.full_name)
    local msgdata = msg:SerializeToString()
    local to_send = {msgname, msgdata}

    tbl_insert(self.sema_send_packet_queue, to_send)
    return self.sema_send:post(1)
end

--
function _M.close(self)
    local sock = self.sock
    if not sock then
        return nil, "not initialized"
    end

    self.state = STATE_CLOSED
    return sock:close()
end

--
function _M.reconnect(self, opts)
    -- sleep before reconnect
    print("connid=" .. tostring(self.id) .. ", reconnect after(s): " .. tostring(self.reconnect_delay_seconds))
    ngx_sleep(self.reconnect_delay_seconds)
    return self:connect(opts)
end

--
local function _connect(self, opts, workerid)
    -- new sock
    local sock, err1 = ngx_tcp()
    if not sock then
        return nil, "no socket -- workerid: " ..
            tostring(workerid) ..
                ", connid:" ..
                    tostring(self.id) ..
                        ", configid: " ..
                            tostring(opts.cfg.id) ..
                                ", cname: " ..
                                    opts.cfg.name ..
                                        ", host: " .. opts.cfg.host .. ", port: " .. tostring(opts.cfg.port)
    end

    --1s, 1s, 1s
    sock:settimeouts(10000, 1000, 1000) -- timeout for connect/send/receive

    local ok, err2
    local host = opts.cfg.host
    if host then
        local port = opts.cfg.port or 8860

        ok, err2 = sock:connect(host, port)
    else
        local path = opts.cfg.path
        if not path then
            return nil, 'neither "host" nor "path" options are specified'
        end

        ok, err2 = sock:connect("unix:" .. path)
    end

    --
    if ok then
        --
        return sock, true
    else
        local errstr =
            "connect failed(" ..
            err2 ..
                ") -- workerid: " ..
                    tostring(workerid) ..
                        ", connid: " ..
                            tostring(self.id) ..
                                ", configid: " ..
                                    tostring(opts.cfg.id) ..
                                        ", cname: " ..
                                            opts.cfg.name ..
                                                ", host: " .. opts.cfg.host .. ", port: " .. tostring(opts.cfg.port)
        return nil, errstr
    end
end

--
function _M.connect(self, opts)
    --
    local workerid = ngx_worker.id()
    local packet_obj
    local pkt

    --
    self.curr_conn = {}

    --
    local sock, errstr = _connect(self, opts, workerid)
    if sock then
        --
        self.sock = sock
        self.curr_conn.upstream = sock

        --
        local packet_type = opts.packet_type or 2
        if packet_type == 1 then
            packet_obj = packet1.new()
        else
            packet_obj = packet2.new()
        end
        self.curr_conn.packet_obj = packet_obj

        --
        self.state = STATE_CONNECTED

        -- connected cb
        opts.connected_cb(self)

        --
        while true do
            -- read packet
            local pkt, err, err_ = packet_obj:read(sock)
            if pkt then
                if opts.got_packet_cb then
                    -- packet dispatcher
                    opts.got_packet_cb(self, pkt)
                end
            elseif err ~= "timeout" then
                print("failed to read packet: connid=" .. tostring(self.id) .. ", " .. err .. " -- " .. err_)
                break
            end
        end

        --
        opts.disconnected_cb(self)

        -- clear sock
        if self.sock then
            self.sock:close()
            self.sock = false
        end
    else
        -- error
        print(errstr)
    end

    -- check reconnect
    if self.state ~= STATE_CLOSED and self.enable_reconnect and self.reconnect_delay_seconds > 0 then
        return self:reconnect(opts)
    end
end

--
function _M.init_sema(self)
    -- create sema
    self.sema_send = ngx_semaphore.new()
    self.sema_send_packet_queue = {}

    local function _sema_send_handler()
        --
        while self.state ~= STATE_CLOSED do
            local ok, err = self.sema_send:wait(10.0) -- wait for 10s
            if not ok then
                if err ~= "timeout" then
                    return nil, "sema_send_handler: failed to wait on sema: " .. err
                end

                print("xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx")
            else
                local curr_conn = self.curr_conn
                local s = curr_conn.upstream
                local packet_obj = curr_conn.packet_obj

                for _, v in ipairs(self.sema_send_packet_queue) do
                    packet_obj:write(s, v[1], v[2], 0)
                end
                self.sema_send_packet_queue = {}
            end
        end
        print("yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy")
    end

    --
    return ngx_thread.spawn(_sema_send_handler)
end

--
function _M.run(self, opts, workerid)
    local function _run_handler()
        self:init_sema()
        return self:connect(opts)
    end
    return ngx_thread.spawn(_run_handler)
end

return _M
