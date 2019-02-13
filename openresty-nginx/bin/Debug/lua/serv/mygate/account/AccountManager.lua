local _M = {
    connectionMap = {},
    accountMap = {},
    --
    nextTokenId = 1
}

--
function _M.CreateAccount(server, userid, data, sock)
    local account = {
        userid = userid,
        data = data,
        session = nil
    }
    _M.accountMap[userid] = account

    local session = server.ssmgr_obj.get_session(sock)
    if session then
        account.session = session
    end

    return account
end

--
function _M.DestroyAccount(userid)
    local account = _M.accountMap[userid]
    if account then
        account.session = nil
        _M.accountMap[userid] = nil
    end
end

--
function _M.getAccount(userid)
    return _M.accountMap[userid]
end

return _M
