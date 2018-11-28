-- Localize
local cwd = (...):gsub('%.[^%.]+$', '') .. "."

local appconfig = require("appconfig")
local config = appconfig.getConfig()

local app_helpers = require("lapis.application")
local respond_to = app_helpers.respond_to
local capture_errors = app_helpers.capture_errors
local assert_error = app_helpers.assert_error

local validate = require("lapis.validate")

local auth = require(cwd .. "authorize")

return function(app)
  app:match("entry", "/", respond_to({
    --
    before = nil,
  
    GET = function(self)
      return { render = "Index", layout = false }
    end,
  
  }))

  app:match("login", "/Login", respond_to({
    --
    before = function(self)
      auth(self, "any") -- redirect to "home" if success
    end,
    
    GET = function(self)
      return { render = "login.Index", layout = false }
    end,
    
    POST = capture_errors(function(self)
      validate.assert_valid(self.params, {
        { "UserName", exists = true, min_length = 2, max_length = 25 },
        { "Password", exists = true, min_length = 2, max_length = 25 },
        --{ "PasswordRepeat", equals = self.params.password },
        --{ "Email", exists = true, min_length = 3 },
        --{ "AcceptTerms", equals = "yes", "You must accept the Terms of Service" }
      })
          
      local Users = require("models.Users")
      local user = Users.getByName(self.params.UserName)
      if user and user.UserName == self.params.UserName and user.Password == self.params.Password then
        local UserRoles = require("models.UserRoles")
        local user_roles = UserRoles.getByUserId(user.Id)
        
        self.session.user = user
        self.session.roles = user_roles
        return { redirect_to = self:url_for("home") }
      else
        assert_error(false, "用户名密码错误!")
      end
    end,
    -- on_error
    function(self)
      return { render = "login.Index", layout = false }
  end)
  }))

  app:match("login_signout", "/Signout", respond_to({
    --
    before = nil,
  
    GET = function(self)
      -- clear session
      self.session.user = nil
      self.session.roles = nil
      return { redirect_to = self:url_for("entry") }
    end,
    
  }))

end