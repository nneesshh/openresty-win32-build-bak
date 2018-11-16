local Model = require("lapis.db.model").Model
local schema = require("lapis.db.schema")
local types = schema.types

local lapis = require("lapis")
local db = require("lapis.db")

local jituuid = require("resty.jit-uuid")

-- Localize
local cwd = (...):gsub('%.[^%.]+$', '') .. "."
local oss_options = require(cwd .. "GameDbUrls").getOptions()

local _M = {
  _db_user_entity = Model:extend(oss_options, "user_attribute", {
    primary_key = "day"
  }),

  _subid = 0
}

--  MailData_MAIL_TYPE_MAIL_TYPE_UNKNOWN = 0,
--  MailData_MAIL_TYPE_MAIL_TYPE_COMPENSATE = 1,
--  MailData_MAIL_TYPE_MAIL_TYPE_FIRST_CHARGE = 2,
--  MailData_MAIL_TYPE_MAIL_TYPE_MONTH_CARD = 3,
--  MailData_MAIL_TYPE_MAIL_TYPE_RANKING_REWARD = 4,
--  MailData_MAIL_TYPE_MAIL_TYPE_GUILD = 5,
--  MailData_MAIL_TYPE_MAIL_TYPE_LV_SHOPPING = 6

function _M.create(mailtype, subject, content, attachment) 
  local subid = _M._subid + 1
  local data = {}
  local res, d1, d2 = db.query(oss_options, "CALL proc_i_create_game_mail(?,?,?,?,?)", subid, mailtype, subject, content, attachment)
  if res then
    local n = #res
    if n >= 2 then
      for i, row in ipairs(res[1]) do  
        table.insert(data, row)
      end
    end
    
    --
    _M._subid = subid
  end
  return data
end

function _M.createPrivate(mailtype, userid, subject, content, attachment) 
  local subid = _M._subid + 1
  local data = {}
  local res, d1, d2 = db.query(oss_options, "CALL proc_i_create_game_mail_private(?,?,?,?,?,?)", subid, mailtype, userid, subject, content, attachment)
  if res then
    local n = #res
    if n >= 2 then
      for i, row in ipairs(res[1]) do  
        table.insert(data, row)
      end
    end
    
    --
    _M._subid = subid
  end
  return data
end

function _M.checkUserId(userId)
    local result = _M._db_user_entity:select("WHERE userid = ?", userId, { fields = "*" });
    return result and #result > 0
end

return _M