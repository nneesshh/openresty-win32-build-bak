require "bootstrap_app"

local _M = {
    _VERSION = "1.0",
    _DESCRIPTION = "",
    callbacks = {}
}

-- Localize
local cwd = (...):gsub("%.[^%.]+$", "") .. "."
local pdir = (...):gsub("%.[^%.]+%.[^%.]+$", "") .. "."

-- initData
function _M.init()
    _M.registerMessageCb()
    return _M
end

--
function _M.dispatch(msgSn, typeName, data)
    print("dispatch:", msgSn, typeName)

    local callback = _M.callbacks[typeName]
    if callback then
        -- parse data
        local msg = callback.pbctor()
        msg:ParseFromString(data)
        callback.cb(msg, msgSn)
    else
        -- try forward
        print("\n\n\n!!!! error: nil message callback, try forward now !!!! -- typeName(" .. typeName .. ")\n\n\n")

        forward(s, msgSn, typeName, data)
    end
end

local tfl = function(str)
    -- trim first letter
    return string.sub(str, 2)
end

-- register message cb
function _M.registerMessageCb()
    _M.callbacks[tfl(Gate_pb.REGISTERACCOUNTSERVICE_META.full_name)] = {
        pbctor = Gate_pb.RegisterAccountService,
        cb = require(cwd .. "service.RegisterAccountService")
    }
    _M.callbacks[tfl(Gate_pb.ACCOUNTLOGINSERVICE_META.full_name)] = {
        pbctor = Gate_pb.AccountLoginService,
        cb = require(cwd .. "service.AccountLoginService")
    }
end

-- send message
function _M.sendMessage(msg, msgSn)
    local meta = getmetatable(msg)
    local msgname = tfl(meta._descriptor.full_name)
    local msgdata = msg:SerializeToString()

    local curr_conn = ngx.ctx.curr_conn
    local s = curr_conn.downstream
    local packet_obj = curr_conn.packet_obj
    packet_obj:write(s, msgname, msgdata, msgSn)
end

return _M.init()
