local tbl_insert = table.insert
local getmetatable = getmetatable
local pairs, ipairs = pairs, ipairs
local str_sub = string.sub

local ngx_worker = ngx.worker
local ngx_timer = ngx.timer
local ngx_thread = ngx.thread
local ngx_say = ngx.say

local ngx_ctx = ngx.ctx
local ngx_semaphore = require("ngx.semaphore")

local _M = {}

--
function _M.init_sema(session)
    -- create sema
    session.sema_send = ngx_semaphore.new()
    session.sema_send_packet_queue = {}

    local function _sema_send_handler()
        while true do
            local ok, err = session.sema_send:wait(10.0) -- wait for 10s
            if not ok then
                if err ~= "timeout" then
                    print("sema_send_handler: failed to wait on sema: " .. err)
                    break
                end
            else
                local curr_conn = ngx_ctx.curr_conn
                local s = curr_conn.downstream
                local packet_obj = curr_conn.packet_obj

                for _, v in ipairs(session.sema_send_packet_queue) do
                    packet_obj:write(s, v[1], v[2], 0)
                end
                session.sema_send_packet_queue = {}
            end
        end
    end

    --
    return ngx_thread.spawn(_sema_send_handler)
end

--
function _M.get_session(ssmgr_name, sock)
    local smfactory = require("serv.network.session_manager_factory")
    local ssmgr = smfactory.get(ssmgr_name)
    if ssmgr then
        return ssmgr:get_session(sock)
    end
end

--
function _M.get_session_by_uuid(ssmgr_name, uuid)
    local smfactory = require("serv.network.session_manager_factory")
    local ssmgr = smfactory.get(ssmgr_name)
    if ssmgr then
        return ssmgr:get_session_by_uuid(uuid)
    end
end

--
function _M.send_raw(data)
    local curr_conn = ngx_ctx.curr_conn
    local s = curr_conn.downstream
    return s:send(data)
end

local tfl = function(str)
    -- trim first letter
    return str_sub(str, 2)
end

--
function _M.send_packet(msg, msgsn)
    local meta = getmetatable(msg)
    local msgname = tfl(meta._descriptor.full_name)
    local msgdata = msg:SerializeToString()

    local curr_conn = ngx_ctx.curr_conn
    local s = curr_conn.downstream
    local packet_obj = curr_conn.packet_obj
    return packet_obj:send_packet(s, msgname, msgdata, msgsn)
end

--
function _M.post_to_sema(session, msg)
    local meta = getmetatable(msg)
    local msgname = tfl(meta._descriptor.full_name)
    local msgdata = msg:SerializeToString()
    local to_send = {msgname, msgdata}

    tbl_insert(session.sema_send_packet_queue, msg)
    return session.sema_send:post(1)
end

--
function _M.broadcast_to_sema(ssmgr_name, msg)
    local smfactory = require("serv.network.session_manager_factory")
    local ssmgr = smfactory.get(ssmgr_name)
    if ssmgr then
        local meta = getmetatable(msg)
        local msgname = tfl(meta._descriptor.full_name)
        local msgdata = msg:SerializeToString()
        local to_send = {msgname, msgdata}

        for k, v in pairs(ssmgr.session_map) do
            local session = v
            tbl_insert(session.sema_send_packet_queue, to_send)
            session.sema_send:post(1)
        end
    end
end

return _M
