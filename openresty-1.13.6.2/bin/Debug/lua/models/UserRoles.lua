local lapis = require("lapis")
local db = require("lapis.db")
local Model = require("lapis.db.model").Model
local schema = require("lapis.db.schema")
local types = schema.types

local jituuid = require("resty.jit-uuid")

local _M = {
  _entity = Model:extend("userroles", {
    primary_key = { "UserId", "RoleId" }
  }),
}

function _M.new() 
  return _M._entity:create({
    id  = jituuid.generate_v4(),
  })
end

function _M.getByUserId(userId) 
  return _M._entity:find_all({ userId }, "UserId")
end

return _M