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
    local lcutil = self.lcutil()
    local stream = self:create_writer_stream()
    lcutil.memory_stream_write_int32(stream, 0) -- userTicketId
    lcutil.memory_stream_write_string(stream, "") -- userName
    lcutil.memory_stream_write_string(stream, "123123") -- pwd
    lcutil.memory_stream_write_string(stream, "1234567890") -- imei
    lcutil.memory_stream_write_string(stream, "xxxxxxxxxx") -- imsi
    lcutil.memory_stream_write_string(stream, "") -- channel
    lcutil.memory_stream_write_string(stream, "") -- subChannel

    local MSGID_LOGIN_REQ = 0x1003
    self.upconn:send_packet(0, MSGID_LOGIN_REQ, stream)
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
