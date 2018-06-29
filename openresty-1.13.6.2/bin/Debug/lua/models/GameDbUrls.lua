local lapis = require("lapis")
local db = require("lapis.db")
local Model = require("lapis.db.model").Model
local schema = require("lapis.db.schema")
local types = schema.types

local split = require("utils.split")

local jituuid = require("resty.jit-uuid")

-- Localize
local cwd = (...):gsub('%.[^%.]+$', '') .. "."
local default_options = require(cwd .. "default_options")

local _M = {
  _game_db_options = nil,
  _entity = Model:extend(default_options, "gamedburls", {
    primary_key = "Id"
  }),
}

function _M.create() 
  local res, err = _M._entity:create({
    Id  = jituuid.generate_v4(),
  })
  assert(res, err)
  return res
end

function _M.getAll(ntype) 
  ntype = ntype or 0
  return _M._entity:select("WHERE type = ?", ntype, { fields = "*" })
end

local function _getGameDbOptions(objList)
  local obj = objList[1]
  
  local pared = {}
  for param in split.each(obj.Url, '%s*;%s*') do
      local k, v = split.first(param, '%s*=%s*')
      pared[k] = v
  end
  
  local host = pared.Server or "127.0.0.1"
  local port = pared.port or 3306
  local path = pared.path
  local database = assert(pared.Database, "`database` missing from config for resty_mysql")
  local user = assert(pared.Uid, "`user` missing from config for resty_mysql")
  local password = pared.Pwd
  local ssl = pared.ssl
  local ssl_verify = pared.ssl_verify
  local timeout = pared.timeout or 10000
  local max_idle_timeout = pared.max_idle_timeout or 10000
  local pool_size = pared.pool_size or 100
  
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
  if not _M._game_db_options then
    local objList = _M.getAll()
    _M._game_db_options = _getGameDbOptions(objList)
  end
  return _M._game_db_options
end

return _M