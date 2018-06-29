local lapis = require("lapis")
local db = require("lapis.db")
local Model = require("lapis.db.model").Model
local schema = require("lapis.db.schema")
local types = schema.types

local jituuid = require("resty.jit-uuid")

-- Localize
local cwd = (...):gsub('%.[^%.]+$', '') .. "."
local default_options = require(cwd .. "default_options")

local _M = {
  _entity = Model:extend(default_options, "roles", {
    primary_key = "id"
  }),
}

function _M.create() 
  local res, err = _M._entity:create({
    Id  = jituuid.generate_v4(),
    Code = "any",
  })
  assert(res, err)
  return res
end

function _M.get(id) 
  return _M._entity:find(id)
end

function _M.getByCode(code) 
  return _M._entity:find({ Code = code })
end

return _M