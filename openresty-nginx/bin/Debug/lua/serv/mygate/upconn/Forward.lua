local tostring, pairs, ipairs = tostring, pairs, ipairs

local _M = {
    upconnMap = {},
    --
    nextConnId = 1,
    running = false
}

-- Localize
local cwd = (...):gsub("%.[^%.]+$", "") .. "."
local pdir = (...):gsub("%.[^%.]+%.[^%.]+$", "") .. "."
local cfg_upconn = require(pdir .. "config.cfg_forward")
local uptcpd = require("serv.network.uptcp")

--
function _M.onUpconnAdd(upconn)
    local token = {
        id = upconn.id,
        upconn = upconn,
        released = false
    }
    _M.upconnMap[token.id] = token
    return token
end

--
function _M.onUpconnRemove(upconn)
    local token = _M.upconnMap[upconn.id]
    if token then
        token.release = true
        _M.upconnMap[token.id] = nil
    end
end

--
function _M.onForward(msg, msgSn)
    print("forward: ", msg, msgSn)
end

--
function _M.createUpconn()
    --
    local nextConnId = _M.nextConnId
    _M.nextConnId = _M.nextConnId + 1

    local upconn = uptcpd:new(nextConnId)
    _M.onUpconnAdd(upconn)
    return upconn
end

--
function _M.destroyUpconn(s)

end

--
function _M.check()
    for k, v in pairs(_M.upconnMap) do
        print("Forward: check connid -- ", tostring(k))
    end
end

--
function _M.start()
    if not _M.running then
        local connected_cb = function(self)
            self:send_raw("\0\0\0\1")
            print("connected_cb, connid=", tostring(self.id))
        end

        local disconnected_cb = function(self)
            print("disconnected_cb, connid=", tostring(self.id))
        end

        local got_packet_cb = function(self, pkt)
            print("got_packet_cb, connid=", tostring(self.id))
        end

        --
        for i, v in ipairs(cfg_upconn) do
            if v.enable then
                for j = 1, 1 do                
                    local upconn = _M.createUpconn()
                    local opts = {
                        cfg = v,
                        connected_cb = connected_cb,
                        disconnected_cb = disconnected_cb,
                        got_packet_cb = got_packet_cb
                    }

                    --
                    upconn:run(opts)
                end
            end
        end

        --
        _M.running = true
    end
end

return setmetatable(
    _M,
    {
        __call = function(_, msg, msgSn)
            _M.onForward(msg, msgSn)
        end
    }
)
