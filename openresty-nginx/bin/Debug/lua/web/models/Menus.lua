local Model = require("lapis.db.model").Model
local schema = require("lapis.db.schema")
local types = schema.types

local uuid = require("uuid")

-- Localize
local cwd = (...):gsub('%.[^%.]+$', '') .. "."
local default_options = require("db.default_mysql_options")

local _M = {
  _db_entity = Model:extend(default_options, "menus", {
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

function _M.get(id) 
  return _M._db_entity:find(id)
end

function _M.getAll(ntype) 
  ntype = ntype or 0
  --[[
  return _M._db_entity:find_all({ ntype }, {
    key = "Type",
    clause = "order by SeqNo"
})]]
  return _M._db_entity:select("WHERE Type = ? AND Hide = 0 ORDER BY SeqNo ASC", ntype, { fields = "*" })
end

return _M