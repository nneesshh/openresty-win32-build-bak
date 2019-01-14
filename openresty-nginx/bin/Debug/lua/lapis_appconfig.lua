-- lapis_appconfig.lua
local _M = {
    _configName = "config_my_umb"
}

_M._config = require("lapis.config")
_M._config(
    _M._configName,
    {
        mysql = {
            host = "127.0.0.1",
            -- host = "192.168.1.213",
            -- host = "192.168.1.110",
            -- host = "192.168.1.10",
            user = "root",
            password = "123123",
            database = "my_umb_web"
        },
        session_name = "my_umb_session",
        secret = "this is my secret string 123456",
        greeting = "hello my umb oss"
    }
)

function _M.getConfigName()
    return _M._configName
end

function _M.getConfig()
    return _M._config.get(_M._configName)
end

return _M
