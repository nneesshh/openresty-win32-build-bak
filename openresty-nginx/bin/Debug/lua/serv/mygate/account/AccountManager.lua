-- Localize
local cwd = (...):gsub("%.[^%.]+$", "") .. "."

local _M = {
    connectionMap = {},
    accountMap = {},
    --
    nextTokenId = 1
}

--
function _M.onConnectionAdd(sock)
    local nextTokenId = _M.nextTokenId
    _M.nextTokenId = _M.nextTokenId + 1

    local token = {
        id = nextTokenId,
        sock = sock,
        userid = nil,
        released = false
    }
    _M.connectionMap[sock] = token
    return token
end

--
function _M.onConnectionRemove(sock)
    local token = _M.connectionMap[sock]
    if token then
        token.release = true
        _M.connectionMap[sock] = nil
    end
end

--
function _M.onAccountAdd(userid, data, sock)
    local account = {
        userid = userid,
        data = data,
        token = nil
    }
    _M.accountMap[userid] = account

    local token = _M.getToken(sock)
    if token then
        token.userid = userid
        account.token = token
    end

    return account
end

--
function _M.onAccountRemove(userid)
    local account = _M.accountMap[userid]
    if account then
        local token = account.token
        if token then
            token.userid = nil
        end

        --
        _M.accountMap[userid] = nil
    end
end

--
function _M.getToken(sock)
    return _M.connectionMap[sock]
end

--
function _M.getAccount(userid)
    return _M.accountMap[userid]
end

return _M
