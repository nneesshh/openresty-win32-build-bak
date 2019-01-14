-- Localize
local cwd = (...):gsub('%.[^%.]+$', '') .. "."
local ostime = os.time
local date = require("date")

local appconfig = require("lapis_appconfig")
local config = appconfig.getConfig()
local split = require("utils.split")

local app_helpers = require("lapis.application")
local respond_to = app_helpers.respond_to
local capture_errors = app_helpers.capture_errors
local assert_error = app_helpers.assert_error

local validate = require("lapis.validate")

local auth = require(cwd .. "authorize")

return function(app)
  app:match("admin_mail", "/AdminMail", respond_to({
    --
    before = function(self)
      auth(self, "any", self.route_name)
    end,
    
    GET = function(self)
      return { render = "admin.Mail", layout = false }
    end,

  }))

  app:match("admin_mail_create", "/AdminMail/Create", respond_to({
    --
    before = function(self)
      auth(self, "any", self.route_name)
    end,
    
    GET = function(self)
      --
      return { render = "admin.MailCreate", layout = false }
    end,

    POST = capture_errors(function(self)
      validate.assert_valid(self.params, {
        { "MailType", exists = true, min_length = 1, max_length = 3 },
        { "Subject", exists = true, min_length = 2, max_length = 500 },
        { "Content", exists = true, min_length = 2, max_length = 500 },
        { "Attachment", min_length = 0, max_length = 500 },
        { "BurnTime", optional=true, min_length = 16, max_length = 22 },
        { "MailtoLevel", min_length = 1, max_length = 3 },
        { "IgnoreRule", min_length = 1, max_length = 3 },
      })
    
      -- check Attachment format
      if self.params.Attachment ~= "" then
        local result = {}
        for elem in split.each(self.params.Attachment, '%s*|%s*') do
          local k, v = split.first(elem, '%s*:%s*')
          if k and v and tonumber(k) then
            table.insert(result, {k, v})
          end
        end
  
        if 0 == #result then
            assert_error(false, "Attachment format is invalid!")
        end
      end

      -- createtime
      local d1 = date(false)
      local createtime = d1:fmt("%F %T")

      -- check burntime
      local burntime = "2999-01-01"
      if self.params.Burntime ~= "" then
        local d2 = date(self.params.Burntime)
        if d2 > d1 then
          burntime = d2:fmt("%F %T")
        end
      end

      -- check mailto_level
      local mailto_level = self.params.MailtoLevel
      if not tonumber(mailto_level) then
        mailto_level = "0"
      end

      -- check ignore_rule
      local ignore_rule = self.params.IgnoreRule
      if not tonumber(ignore_rule) then
        ignore_rule = "0"
      end

      local Mail = require("models.Mail")
      
      local obj = Mail.create(self.params.MailType, self.params.Subject, self.params.Content, self.params.Attachment,
                              createtime, burntime, mailto_level, ignore_rule)
      if obj and self.session.user then
        self.success_infos = { "Success" }
        return { render = "admin.MailCreate", layout = false }
      else
        --assert_error(false, "xxxx错误!")
      end
    end,
    -- on_error
    function(self)
        return { render = "admin.MailCreate", layout = false }
    end)
  }))

  app:match("admin_mail_create_private", "/AdminMail/CreatePrivate", respond_to({
    --
    before = function(self)
      auth(self, "any", self.route_name)
    end,
    
    GET = function(self)
      --
      return { render = "admin.MailCreatePrivate", layout = false }
    end,

    POST = capture_errors(function(self)
      validate.assert_valid(self.params, {
        { "MailType", exists = true, min_length = 1, max_length = 3 },
        { "UserId", exists = true, min_length = 2, max_length = 50 },        
        { "Subject", exists = true, min_length = 2, max_length = 500 },
        { "Content", exists = true, min_length = 2, max_length = 500 },
        { "Attachment", min_length = 0, max_length = 500 },
      })
    
      -- check Attachment format
      if self.params.Attachment ~= "" then
        local result = {}
        for elem in split.each(self.params.Attachment, '%s*|%s*') do
          local k, v = split.first(elem, '%s*:%s*')
          if k and v and tonumber(k) then
            table.insert(result, {k, v})
          end
        end
  
        if 0 == #result then
            assert_error(false, "Attachment format is invalid!")
        end
      end
      
      local PlayerManage = require("models.PlayerManage")
      
      -- check userid 
      local bExist = PlayerManage.checkUserId(self.params.UserId)
      if not bExist then
        assert_error(false, "UserId(" .. tostring(self.params.UserId) ..  ") not exist!!!")
      end

      local Mail = require("models.Mail")
      
      local obj = Mail.createPrivate(self.params.MailType, self.params.UserId, self.params.Subject, self.params.Content, self.params.Attachment)
      if obj and self.session.user then
        self.success_infos = { "Success" }
        return { render = "admin.MailCreatePrivate", layout = false }
      else
        --assert_error(false, "xxxx错误!")
      end
    end,
    -- on_error
    function(self)
        return { render = "admin.MailCreatePrivate", layout = false }
    end)
  }))

end