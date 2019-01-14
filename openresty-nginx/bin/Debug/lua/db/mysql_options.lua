local _M = {
  _VERSION = "1.0.0.1",
  _DESCRIPTION = "options for database..."
}

-- Localize
local cwd = (...):gsub("%.[^%.]+$", "") .. "."
local split = require("utils.split")

function _M.new(settings)
  if type(settings) == "string" then
    --[[
      mysql_url = 'Server=127.0.0.1;Database=sandbox;Uid=root;Pwd=123123;CharSet=utf8;SslMode=None'
    ]]
    local mysql_url = settings
    local parsed = {}

    for param in split.each(mysql_url, "%s*;%s*") do
      local k, v = split.first(param, "%s*=%s*")
      parsed[k] = v
    end

    local host = parsed.Server or "127.0.0.1"
    local port = parsed.Port or 3306
    local path = parsed.Path
    local database = assert(parsed.Database, "`database` missing from config for resty_mysql")
    local user = assert(parsed.Uid, "`user` missing from config for resty_mysql")
    local password = parsed.Pwd
    local ssl = parsed.Ssl
    local ssl_verify = parsed.SslVerify
    local timeout = parsed.Timeout or 10000
    local max_idle_timeout = parsed.MaxIdleTimeout or 10000
    local pool_size = parsed.PoolSize or 100

    local options = {
      database = database,
      user = user,
      password = password,
      ssl = ssl,
      ssl_verify = ssl_verify,
      charset = "utf8"
    }
    if path then
      options.path = path
    else
      options.host = host
      options.port = port
    end

    options.pool = user .. ":" .. database .. ":" .. host .. ":" .. port

    return options
  elseif type(settings) == "table" then
    --[[
      mysql_config = {
        host = "127.0.0.1",
        user = "root",
        password = "123123",
        database = "my_umb_web"
      },
    ]]
    local mysql_config = settings

    local host = mysql_config.host or "127.0.0.1"
    local port = mysql_config.port or 3306
    local path = mysql_config.path
    local database = assert(mysql_config.database, "`database` missing from config for resty_mysql")
    local user = assert(mysql_config.user, "`user` missing from config for resty_mysql")
    local password = mysql_config.password
    local ssl = mysql_config.ssl
    local ssl_verify = mysql_config.ssl_verify
    local timeout = mysql_config.timeout or 10000
    local max_idle_timeout = mysql_config.max_idle_timeout or 10000
    local pool_size = mysql_config.pool_size or 100

    local options = {
      database = database,
      user = user,
      password = password,
      ssl = ssl,
      ssl_verify = ssl_verify,
      charset = "utf8"
    }
    if path then
      options.path = path
    else
      options.host = host
      options.port = port
    end

    options.pool = user .. ":" .. database .. ":" .. host .. ":" .. port

    return options
  else
    error("unsupported settings type for db_options!!! type(settings)=" .. type(setting))
  end
end

return _M
