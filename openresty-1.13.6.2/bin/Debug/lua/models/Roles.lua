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

function _M.new() 
  return _M._entity:create({
    id  = jituuid.generate_v4(),
    code = "any",
  })
end

function _M.get(id) 
  return _M._entity:find(id)
end

function _M.getByCode(code) 
  return _M._entity:find({ Code = code })
end

return _M