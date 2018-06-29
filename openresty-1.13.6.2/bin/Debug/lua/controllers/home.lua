-- Localize
local cwd = (...):gsub('%.[^%.]+$', '') .. "."

local appconfig = require("appconfig")
local config = appconfig.getConfig()

local app_helpers = require("lapis.application")
local respond_to = app_helpers.respond_to
local capture_errors = app_helpers.capture_errors

local auth = require(cwd .. "authorize")

return function(app)
  app:match("home", "/", respond_to({
    --
    before = nil,
  
    GET = function(self)
      return { render = "home.Index", layout = false }
    end,
  
  }))

  app:match("welcome", "/home/welcome", respond_to({
    --
    before = function(self)
      auth(self, "any")
    end,
  
    GET = function(self)
      return { render = "home.Welcome" }
    end,
    
  }))

end