local Model = require("lapis.db.model").Model
local schema = require("lapis.db.schema")
local types = schema.types

local split = require("utils.split")

local uuid = require("uuid")

-- Localize
local cwd = (...):gsub('%.[^%.]+$', '') .. "."
local default_options = require("db.default_mysql_options")
local db_options = require("db.mysql_options")

local _M = {
  _db_entity = Model:extend(default_options, "gamedburls", {
    primary_key = "Id"
  }),

  --
  _game_db_options = false,
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
  
end

function _M.getOptions()
  -- load options from db if not cached yet
  if not _M._game_db_options then
    local objList = _M.getAll()
    if #objList >= 1 then
      local obj = objList[1]
      _M._game_db_options = db_options.new(obj.Url)
    end
  end
  return _M._game_db_options
end

return _M