local Model = require("lapis.db.model").Model
local schema = require("lapis.db.schema")
local types = schema.types

local lapis = require("lapis")
local db = require("lapis.db")

local uuid = require("uuid")

-- Localize
local cwd = (...):gsub('%.[^%.]+$', '') .. "."
local oss_options = require(cwd .. "GameDbUrls").getOptions()

local _M = {
  _db_user_entity = Model:extend(oss_options, "user_attribute", {
    primary_key = "userid"
  }),

}

function _M.checkUserId(userId)
  local result = _M._db_user_entity:select("WHERE userid = ?", userId, { fields = "*" });
  return result and #result > 0
end

function _M.getPlayerOnline(userId) 
  local data = {}
  local res, d1, d2 = db.query(oss_options, "CALL __oss_do_player_query_online(?)", userId)
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

function _M.getPlayerCharge(userId, beginTime, endTime) 
  local data = {}
  local res, d1, d2 = db.query(oss_options, "CALL __oss_do_player_query_charge(?,?,?)", userId, beginTime, endTime)
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