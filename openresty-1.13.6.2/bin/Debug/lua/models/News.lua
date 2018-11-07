local Model = require("lapis.db.model").Model
local schema = require("lapis.db.schema")
local types = schema.types

local jituuid = require("resty.jit-uuid")

-- Localize
local cwd = (...):gsub('%.[^%.]+$', '') .. "."
local default_options = require(cwd .. "default_options")

local _M = {
  _db_entity = Model:extend(require(cwd .. "GameDbUrls").getOptions(), "_oss_news", {
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

function _M.update(obj) 
  local res, err = obj:update("CreateBy", "CreateTime", "Content")
  assert(res, err)
end

function _M.delete(obj) 
  local res, err = obj:delete(obj)
  assert(res, err)
end

function _M.get(id) 
  return _M._db_entity:find(id)
end

function _M.getAll() 
  return _M._db_entity:select("WHERE 1=1 ORDER BY CreateTime DESC", { fields = "*" })
end

return _M