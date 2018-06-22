-- Localize
local cwd = (...):gsub('%.[^%.]+$', '') .. "."

local lapis = require("lapis")
local appconfig = require("appconfig")
local config = appconfig.getConfig()
local respond_to = require("lapis.application").respond_to

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