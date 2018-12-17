local Model = require("lapis.db.model").Model
local schema = require("lapis.db.schema")
local types = schema.types

local split = require("utils.split")

local uuid = require("uuid")

-- Localize
local cwd = (...):gsub('%.[^%.]+$', '') .. "."
local default_options = require(cwd .. "default_options")

local _M = {
  _game_db_options = nil,
  _db_entity = Model:extend(default_options, "gamedburls", {
    primary_key = "Id"
  }),
}

function _M.create() 
  local res, err = _M._db_entity:create({
    Id  = uuid.generate(),
  })
  assert(res, err)
  return res
end

function _M.getAll(ntype) 
  ntype = ntype or 0
  return _M._db_entity:select("WHERE type = ?", ntype, { fields = "*" })
end

local function _getOptionsFromGameDbUrls(objList)
  local obj = objList[1]
  
  local parsed = {}
  for param in split.each(obj.Url, '%s*;%s*') do
      local k, v = split.first(param, '%s*=%s*')
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
end

function _M.getOptions()
  if not _M._options then
    local objList = _M.getAll()
    _M._options = _getOptionsFromGameDbUrls(objList)
  end
  return _M._options
end

return _M