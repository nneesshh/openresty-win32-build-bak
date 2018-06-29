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
  _entity = Model:extend(default_options, "userroles", {
    primary_key = { "UserId", "RoleId" }
  }),
}

function _M.create() 
  local res, err = _M._entity:create({
    Id  = jituuid.generate_v4(),
  })
  assert(res, err)
  return res
end

function _M.getByUserId(userId) 
  return _M._entity:find_all({ userId }, "UserId")
end

return _M