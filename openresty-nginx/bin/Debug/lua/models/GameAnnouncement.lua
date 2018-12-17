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
  _db_entity = Model:extend(oss_options, "game_announcement", {
    primary_key = "id"
  }),
}

--  MailData_MAIL_TYPE_MAIL_TYPE_UNKNOWN = 0,
--  MailData_MAIL_TYPE_MAIL_TYPE_COMPENSATE = 1,
--  MailData_MAIL_TYPE_MAIL_TYPE_FIRST_CHARGE = 2,
--  MailData_MAIL_TYPE_MAIL_TYPE_MONTH_CARD = 3,
--  MailData_MAIL_TYPE_MAIL_TYPE_RANKING_REWARD = 4,
--  MailData_MAIL_TYPE_MAIL_TYPE_GUILD = 5,
--  MailData_MAIL_TYPE_MAIL_TYPE_LV_SHOPPING = 6

function _M.create(deadlineTime, playInterval, content) 
  local data = {}
  local res, d1, d2 = db.query(oss_options, "CALL __oss_create_game_announcement(?,?,?)", deadlineTime, playInterval, content)
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

function _M.get(id) 
  return _M._db_entity:find(id)
end

function _M.getAll() 
  return _M._db_entity:select("WHERE 1=1 ORDER BY id DESC", { fields = "*" })
end

return _M