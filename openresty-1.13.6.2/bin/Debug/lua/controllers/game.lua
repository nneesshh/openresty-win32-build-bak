-- Localize
local cwd = (...):gsub('%.[^%.]+$', '') .. "."

local appconfig = require("appconfig")
local config = appconfig.getConfig()

local app_helpers = require("lapis.application")
local respond_to = app_helpers.respond_to
local capture_errors = app_helpers.capture_errors

local auth = require(cwd .. "authorize")

return function(app)
  app:match("gamenews", "/GameNews", respond_to({
    --
    before = nil,
  
    GET = function(self)
      local News = require("models.News")
      local newsList = News.getAll()
      
      if #newsList > 0 then
        self.CurrentNews = newsList[1]
      end

      return { render = "game.News", layout = false }
    end,
  
  }))

end