local Model = require("lapis.db.model").Model
local schema = require("lapis.db.schema")
local types = schema.types

local uuid = require("uuid")

local lapis = require("lapis")
local db = require("lapis.db")

-- Localize
local cwd = (...):gsub('%.[^%.]+$', '') .. "."
local oss_options = require(cwd .. "GameDbUrls").getOptions()

local _M = {
  
}

function _M.getData(theQueryTime) 
  local data = {}
  local res, d1, d2 = db.query(oss_options, "CALL __oss_do_stats_online_snapshot(?)", theQueryTime)
  if res then
    local n = #res
    if n >= 2 then
      for i, row in ipairs(res[1]) do  
        table.insert(data, row)
      end
    end
  end
  return data
end

return _M