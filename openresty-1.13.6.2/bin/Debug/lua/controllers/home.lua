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
    before = nil, -- auth
  
    GET = function(self)
      return { render = "home.index" }
    end,
    
    POST = function(self)
      return { redirect_to = self:url_for("index") }
    end
  }))
end