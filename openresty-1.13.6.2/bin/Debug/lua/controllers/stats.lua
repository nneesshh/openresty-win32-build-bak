-- Localize
local cwd = (...):gsub('%.[^%.]+$', '') .. "."
local ostime = os.time

local appconfig = require("appconfig")
local config = appconfig.getConfig()

local app_helpers = require("lapis.application")
local respond_to = app_helpers.respond_to
local capture_errors = app_helpers.capture_errors
local assert_error = app_helpers.assert_error

local validate = require("lapis.validate")

local auth = require(cwd .. "authorize")

return function(app)
  app:match("statsonlinehour", "/StatsUserOnlineHour", respond_to({
    --
    before = function(self)
      auth(self, "any", self.route_name)
    end,
    
    --
    GET = function(self)
      local model = require("models.OssStatsOnlineHour")
      local d = require("date")(false)
      local page = model.getPage(d:fmt("%F"))
      
      if page then
        self.StatsPage = page
      end
      
      return { render = "stats.UserOnlineHour" }
    end,
    
  }))

  app:match("statsonline", "/StatsUserOnline", respond_to({
    --
    before = function(self)
      auth(self, "any", self.route_name)
    end,
    
    --
    GET = function(self)
      local model = require("models.OssStatsOnline")
      local d = require("date")(false)
      local page = model.getPage(d:fmt("%F"))
      
      if page then
        self.StatsPage = page
      end
      
      return { render = "stats.UserOnline" }
    end,
    
  }))

  app:match("statscharge", "/StatsUserCharge", respond_to({
    --
    before = function(self)
      auth(self, "any", self.route_name)
    end,
    
    --
    GET = function(self)
      local model = require("models.OssStatsCharge")
      local d = require("date")(false)
      local page = model.getPage(d:fmt("%F"))
      
      if page then
        self.StatsPage = page
      end
      
      return { render = "stats.UserCharge" }
    end,
    
  }))

  app:match("statsdiamond", "/StatsUserDiamond", respond_to({
    --
    before = function(self)
      auth(self, "any", self.route_name)
    end,
    
    --
    GET = function(self)
      local model = require("models.OssStatsDiamond")
      local d = require("date")(false)
      local page = model.getPage(d:fmt("%F"))
      
      if page then
        self.StatsPage = page
      end
      
      return { render = "stats.UserDiamond" }
    end,
    
  }))

  app:match("statsonlinesnapshot", "/StatsUserOnlineSnapshot", respond_to({
    --
    before = function(self)
      auth(self, "any", self.route_name)
    end,
    
    --
    GET = function(self)
      local model = require("models.OssStatsOnlineSnapshot")
      local d = require("date")(false)
      local page = model.getPage(d:fmt("%F"))
      
      if page then
        self.StatsPage = page
      end
      
      return { render = "stats.UserOnlineSnapshot" }
    end,
    
  }))

end