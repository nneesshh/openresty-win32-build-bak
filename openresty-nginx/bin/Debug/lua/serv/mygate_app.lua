local _M = {
    _VERSION = "1.0.0.1",
    _DESCRIPTION = "It is the app entry ...",
    --
    ssmgr = nil,
}

-- Localize
local smfactory = require("serv.network.session_manager_factory")
local serverd = require("serv.network.server")
local tbl_concat = table.concat

local cwd = (...):gsub("%.[^%.]+$", "") .. "."
local msgDispatcher = require(cwd .. "mygate.client.MessageDispatcher")

local function _onClientConnected(s)
end

local function _onClientDisconnected(s)
end

local function _onClientGotPacket(pkt)
    msgDispatcher.dispatch(pkt.sn, pkt.name, tbl_concat(pkt.data))
end

--
function _M.serve()
    --
    local ok, err = serverd.serve(_M.ssmgr, _onClientConnected, _onClientDisconnected, _onClientGotPacket)
    if not ok then
        ngx.log(ngx.ERR, err)
    end
    ngx.exit(ok)
end

function _M.init()
    -- create session manager
    _M.ssmgr = smfactory.create("mygate_server")

    -- debug only with "enable_code_cache" is 0
    require("init_worker_stream_lazy")
    return _M
end

return _M.init()
