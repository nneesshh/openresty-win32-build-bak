local _M = {
    _VERSION = "1.0.0.1",
    _DESCRIPTION = "It is the app entry ...",

    --
    isUpconnReady = false
}

-- Localize
local cwd = (...):gsub("%.[^%.]+$", "") .. "."
local pcserverd = require(cwd .. "network.server")
local aMgr = require(cwd .. "mygate.account.AccountManager")
local msgDispatcher = require(cwd .. "mygate.client.MessageDispatcher")

local function _onClientConnected(s)
    aMgr.onConnectionAdd(s)
end

local function _onClientDisconnected(s)
    aMgr.onConnectionRemove(s)
end

local function _onClientGotPacket(pkt)
    msgDispatcher.dispatch(pkt.sn, pkt.name, table.concat(pkt.data))
end

--
function _M.setUpconnReady(b)
    _M.isUpconnReady = b
end

--
function _M.isUpconnReady()
    return _M.isUpconnReady
end

--
function _M.serve()
    local ok, err = pcserverd.serve(_onClientConnected, _onClientDisconnected, _onClientGotPacket)
    if not ok then
        ngx.log(ngx.ERR, err)
    end
end

return _M
