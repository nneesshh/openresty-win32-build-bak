local lapis = require("lapis")
local appconfig = require("appconfig")
local config = appconfig.getConfig()

local function copy(obj, seen)
  if type(obj) ~= 'table' then return obj end
  if seen and seen[obj] then return seen[obj] end
  local s = seen or {}
  local res = setmetatable({}, getmetatable(obj))
  s[obj] = res
  for k, v in pairs(obj) do res[copy(k, s)] = copy(v, s) end
  return res
end

if config.postgres then
  
  local options = {}
  for k, v in pairs(config.postgres) do 
    options[k] = v
  end
  return options
  
elseif config.mysql then

  local mysql_config = assert(config.mysql, "missing mysql configuration for resty_mysql")
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
    charset = "utf8",
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
  return error("You have to configure either postgres or mysql")
end