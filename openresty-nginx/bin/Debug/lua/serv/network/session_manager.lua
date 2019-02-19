-- Localize
local setmetatable = setmetatable
local pairs = pairs
local cwd = (...):gsub("%.[^%.]+$", "") .. "."
local client_helper = require(cwd .. "client_helper")

local _M = {
    --
    next_session_id = 1
}

--
local mt = {__index = _M}

function _M.new(self, id, name)
    return setmetatable(
        {
            id = id,
            name = name,
            session_map = {},
            uuid_2_session_map = {}
        },
        mt
    )
end

--
function _M.create_session(self, sock)
    local next_session_id = _M.next_session_id
    _M.next_session_id = _M.next_session_id + 1

    local session = {
        id = next_session_id,
        sock = sock,
        --
        sema_send = false,
        sema_send_packet_queue = false,
        --
        uuid = nil,
        released = false
    }
    self.session_map[sock] = session

    client_helper.init_sema(session)
    return session
end

--
function _M.destroy_session(self, session)
    if session then
        session.release = true
        self.session_map[session.sock] = nil
    end
end

--
function _M.get_session(self, sock)
    return self.session_map[sock]
end

--
function _M.get_session_by_uuid(self, uuid)
    local session = self.uuid_2_session_map[uuid]
    if not session then
        for k, v in pairs(session_map) do
            if v.uuid and v.uuid == uuid then
                session = v

                --
                self.uuid_2_session_map[uuid] = v
            end
        end
    end
    return session
end

return _M
