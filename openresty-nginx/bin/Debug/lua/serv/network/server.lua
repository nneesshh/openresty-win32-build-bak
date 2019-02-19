local _M = {
    _VERSION = "1.0.0.1",
    _DESCRIPTION = "serverd for persistent connection ..."
}

local tostring = tostring

local ngx_worker = ngx.worker
local NGX_OK = ngx.OK

local ngx_req = ngx.req
local ngx_ctx = ngx.ctx

-- Localize
local cwd = (...):gsub("%.[^%.]+$", "") .. "."
local packet1 = require(cwd .. "outer_packet")
local packet2 = require(cwd .. "inner_packet")

--
function _M.serve(ssmgr_obj, connected_cb, disconnected_cb, got_packet_cb, packet_type)
    local workerid = ngx_worker.id()
    local s = ngx_req.socket()
    local packet_obj
    local pkt

    ngx_ctx.curr_conn = {}

    --
    if not s then
        return nil, "no socket: workerid: " .. workerid
    end
    ngx_ctx.curr_conn.downstream = s

    --
    packet_type = packet_type or 1
    if packet_type == 1 then
        packet_obj = packet1.new()
    else
        packet_obj = packet2.new()
    end
    ngx_ctx.curr_conn.packet_obj = packet_obj

    --1s, 1s, 1s
    s:settimeouts(1000, 1000, 1000) -- timeout for connect/send/receive

    local session = ssmgr_obj:create_session(s)
    connected_cb(s)

    --[[ --IOCP DOES NOT SUPPORT check_client_abort
    local function my_cleanup()
      --ngx.exit(499)
      _M.disconnected_cb(s)
    end

    local ok, regerr = ngx.on_abort(my_cleanup)
    if not ok then
      ngx.log(ngx.ERR, "failed to register the on_abort callback: ", regerr)
      ngx.exit(500)
    end
    --]]
    
    local idle_count = 0
    local MAX_IDLE_COUNT = 25 * 60

    while true do
        -- read packet
        local pkt, err, err_ = packet_obj:read(s)
        if pkt then
            if got_packet_cb then
                -- packet dispatcher
                got_packet_cb(pkt)
            end

            -- clear idle count
            idle_count = 0
        elseif err == "timeout" then
            idle_count = idle_count + 1

            -- idle no more 25 mins
            if idle_count >= MAX_IDLE_COUNT then
                print("idle kick for timeout: sessionid=" .. tostring(session.id))
                break
            end
        else
            print("failed to read packet: sessionid=" .. tostring(session.id) .. ", " .. err .. " -- " .. err_)
            break
        end
    end

    --
    disconnected_cb(s)
    ssmgr_obj:destroy_session(session)
    return NGX_OK
end

return _M
