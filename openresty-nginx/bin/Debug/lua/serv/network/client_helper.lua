local tbl_insert = table.insert
local getmetatable = getmetatable
local ipairs = ipairs
local str_sub = string.sub

local semaphore = require("ngx.semaphore")

local _M = {}

local tfl = function(str)
    -- trim first letter
    return str_sub(str, 2)
end

--
function _M.init_sema(session)
    -- create sema
    session.sema_send = semaphore.new()
    session.sema_send_buffer = {}

    local function sema_send_handler()
        while true do
            local ok, err = session.sema_send:wait(30) -- wait for 30s
            if not ok then
                if err ~= "timeout" then
                    return nil, "sema_send_handler: failed to wait on sema: " .. err
                end
            else
                local curr_conn = ngx.ctx.curr_conn
                local s = curr_conn.downstream
                local packet_obj = curr_conn.packet_obj

                for _, v in ipairs(session.sema_send_buffer) do
                    packet_obj:write(s, v[1], v[2], 0)
                end
                session.sema_send_buffer = {}
            end
        end
    end

    --
    return ngx.thread.spawn(sema_send_handler)
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
function _M.send(msg, msgsn)
    local meta = getmetatable(msg)
    local msgname = tfl(meta._descriptor.full_name)
    local msgdata = msg:SerializeToString()

    local curr_conn = ngx.ctx.curr_conn
    local s = curr_conn.downstream
    local packet_obj = curr_conn.packet_obj
    return packet_obj:write(s, msgname, msgdata, msgsn)
end

--
function _M.post_to_sema(session, msg)
    local meta = getmetatable(msg)
    local msgname = tfl(meta._descriptor.full_name)
    local msgdata = msg:SerializeToString()
    local to_send = {msgname, msgdata}

    tbl_insert(session.sema_send_buffer, msg)
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
            tbl_insert(session.sema_send_buffer, to_send)
            session.sema_send:post(1)
        end
    end
end

return _M
