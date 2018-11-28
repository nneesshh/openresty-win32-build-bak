-- Localize
local cwd = (...):gsub('%.[^%.]+$', '') .. "."

local appconfig = require("appconfig")
local config = appconfig.getConfig()

local app_helpers = require("lapis.application")
local respond_to = app_helpers.respond_to
local capture_errors = app_helpers.capture_errors

local auth = require(cwd .. "authorize")

return function(app)
  app:match("home", "/Home", respond_to({
    --
    before = function(self)
      auth(self, "any") -- redirect to "home" if success
    end,
  
    GET = function(self)
      return { render = "home.Index", layout = false }
    end,
  
  }))

  app:match("home_welcome", "/HomeWelcome", respond_to({
    --
    before = function(self)
      auth(self, "any", self.route_name)
    end,
  
    GET = function(self)
      return { render = "home.Welcome", layout = false }
    end,
    
  }))

end