local Model = require("lapis.db.model").Model
local schema = require("lapis.db.schema")
local types = schema.types

local jituuid = require("resty.jit-uuid")

-- Localize
local cwd = (...):gsub('%.[^%.]+$', '') .. "."
local default_options = require(cwd .. "default_options")

local _M = {
  _db_entity = Model:extend(default_options, "menus", {
    primary_key = "Id"
  }),
}

function _M.create() 
  local res, err = _M._db_entity:create({
    Id  = jituuid.generate_v4(),
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
  return _M._db_entity:select("WHERE Type = ? and hide = 0 ORDER BY SeqNo ASC", ntype, { fields = "*" })
end

return _M