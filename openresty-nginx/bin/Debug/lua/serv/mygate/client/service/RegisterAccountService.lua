local _M = {}

--[[
	// 注册RESULT
	enum RESULT {
		OK = 0;
		UID_OR_PWD_TOO_SHORT = -1; // 账号或者密码长度少于6
		UID_ALREADY_EXISTS = -2; // 账号已经存在
		UID_MUST_START_WITH_A_LETTER = -3; // 账号首字符不是字母
		EMAIL_INVALID = -4; // 无效的email
		DB_ERROR = -8888; // 数据库故障
		ASYNC_WAIT = -9999; // 异步等待
	}
]]
-- Localize
local pdir = (...):gsub("%.[^%.]+%.[^%.]+$", "") .. "."
local ppdir = (...):gsub("%.[^%.]+%.[^%.]+%.[^%.]+$", "") .. "."
local model = require(ppdir .. "models.GateAccount")

--
function _M.onResponse(msg, msgSn)
    local uid = msg.req.uid
    local pwd = msg.req.pwd
    local nick = msg.req.nick
    local email = msg.req.email
    local sponsor = msg.req.sponsor_uid

    msg.resp.result = 0

    --
     _M.sendResponse(msg, msgSn)
end

--
function _M.sendResponse(msg, msgSn)
    print("sendRegisterAccountService")

    local msg = Gate_pb.RegisterAccountService()
    msg.req.uid = robot.unit:userid()
    msg.req.pwd = robot.unit:pwd()
    msg.req.nick = "test"
    msg.req.email = "test@ab.com"
    msg.req.sponsor_uid = "sponsor"

    client_helper.send(msg, 0)
end

-- make service callable
return setmetatable(
    _M,
    {
        __call = function(_, msg, msgSn)
            _M.onResponse(msg, msgSn)
        end
    }
)
