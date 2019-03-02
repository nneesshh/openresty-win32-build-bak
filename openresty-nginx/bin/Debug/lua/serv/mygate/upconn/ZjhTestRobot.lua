local tostring, pairs, ipairs = tostring, pairs, ipairs

local _M = {}

local mt = {__index = _M}

function _M.new(self, upconn)
    return setmetatable(
        {
            upconn = upconn
        },
        mt
    )
end

function _M.sendBadMsg(self)
    self.upconn:send_raw("\0\0\0\1")
end

function _M.sendLogin(self)
    self.upconn:send_raw("\0\0\0\1")
end

function _M.start(self)
    print("born now")
    --self:sendBadMsg();

    -- 

end

function _M.finish(self)
    print("die now")
end

return _M
