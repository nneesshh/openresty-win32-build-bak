local _M = {}

--[[
    // 通用错误号
    message ErrorNo {
        enum ERROR_NO {
            RELOGIN = -9000; // 账号重新登录
            IP_IS_BANNED = -9001; // IP 被屏蔽
            UID_IS_BANNED = -9002; // UID 被屏蔽
        }

        required int32 error_no = 1;
        required bytes desc = 2;
    }

    // 登录RESULT
    enum RESULT {
        OK = 0;
        UID_OR_PWD_IS_NOT_VALID = -1; // 账号或者密码错误
        USER_ASSETS_LOAD_FAILED = -2; // 用户资料加载失败
        TOO_MANY_REQUEST = -3; // 账号繁忙
        GAME_SERVER_NOT_READY = -4; // 服务器未就绪
        NEED_ACTIVATE = -5; // 账户尚未激活
    }
]]
-- Localize
local pdir = (...):gsub("%.[^%.]+%.[^%.]+$", "") .. "."
local ppdir = (...):gsub('%.[^%.]+%.[^%.]+%.[^%.]+$', '') .. "."
local model = require(ppdir .. "models.GateAccount")
local aMgr = require(ppdir .. "account.AccountManager")

--
function _M.onResponse(msg, msgSn)
    local account

    local uid = msg.req.uid
    local pwd = msg.req.pwd

    -- ensure account exist
    if ngx.account then
        account = ngx.account
    else
        account = aMgr.getAccount(uid)
        if not account then
            -- load from db
            local res = model.get(uid)
            if res then
                account = aMgr.onAccountAdd(res.userid, res, ngx.downstream)
            end
        end
    end

    if not account then
        -- -1
        msg.resp.result = Gate_pb.E_ACCOUNTLOGINSERVICE_RESULT_UID_OR_PWD_IS_NOT_VALID
    else
        if account.data.pwd ~= pwd then
            -- -1
            msg.resp.result = Gate_pb.E_ACCOUNTLOGINSERVICE_RESULT_UID_OR_PWD_IS_NOT_VALID
        else
            -- ok
            msg.resp.result = 0
        end
    end

    --
    _M.sendResponse(msg, msgSn)
end

function _M.sendResponse(msg, msgSn)
    print("sendAccountLoginService")

    if not msg then
        msg = Gate_pb.AccountLoginService()
        msg.resp.result = 0
    end

    local msgDispatcher = require(pdir .. "MessageDispatcher")
    msgDispatcher.sendMessage(msg, msgSn)
end

return setmetatable(
    _M,
    {
        __call = function(_, msg, msgSn)
            _M.onResponse(msg, msgSn)
        end
    }
)
