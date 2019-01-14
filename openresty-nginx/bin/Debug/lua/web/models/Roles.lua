local Model = require("lapis.db.model").Model
local schema = require("lapis.db.schema")
local types = schema.types

local uuid = require("uuid")

-- Localize
local cwd = (...):gsub('%.[^%.]+$', '') .. "."
local default_options = require("db.default_mysql_options")

local _M = {
  _db_entity = Model:extend(default_options, "roles", {
    primary_key = "id"
  }),
}

function _M.create() 
  local res, err = _M._db_entity:create({
    Id  = uuid.generate(),
    Code = "any",
  })
  assert(res, err)
  return res
end

function _M.get(id) 
  return _M._db_entity:find(id)
end

function _M.getByCode(code) 
  return _M._db_entity:find({ Code = code })
end

return _M