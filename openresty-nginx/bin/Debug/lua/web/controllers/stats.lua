-- Localize
local cwd = (...):gsub('%.[^%.]+$', '') .. "."
local ostime = os.time
local date = require("date")

local appconfig = require("lapis_appconfig")
local config = appconfig.getConfig()

local app_helpers = require("lapis.application")
local respond_to = app_helpers.respond_to
local capture_errors = app_helpers.capture_errors
local assert_error = app_helpers.assert_error

local validate = require("lapis.validate")

local auth = require(cwd .. "authorize")

return function(app)
  app:match("stats_onlinehour", "/StatsUserOnlineHour", respond_to({
    --
    before = function(self)
      auth(self, "any", self.route_name)
    end,
    
    --
    GET = function(self)
      local model = require("models.OssStatsOnlineHour")
      local d = date(false)
      local page = model.getPage(d:fmt("%F"))
      
      if page then
        self.StatsPage = page
      end
      
      return { render = "stats.UserOnlineHour", layout = false }
    end,
    
  }))

  app:match("stats_online", "/StatsUserOnline", respond_to({
    --
    before = function(self)
      auth(self, "any", self.route_name)
    end,
    
    --
    GET = function(self)
      local model = require("models.OssStatsOnline")
      local d = date(false)
      local page = model.getPage(d:fmt("%F"))
      
      if page then
        self.StatsPage = page
      end
      
      return { render = "stats.UserOnline", layout = false }
    end,
    
  }))

  app:match("stats_charge", "/StatsUserCharge", respond_to({
    --
    before = function(self)
      auth(self, "any", self.route_name)
    end,
    
    --
    GET = function(self)
      local model = require("models.OssStatsCharge")
      local d = date(false)
      local page = model.getPage(d:fmt("%F"))
      
      if page then
        self.StatsPage = page
      end
      
      return { render = "stats.UserCharge", layout = false }
    end,
    
  }))

  app:match("stats_diamond", "/StatsUserDiamond", respond_to({
    --
    before = function(self)
      auth(self, "any", self.route_name)
    end,
    
    --
    GET = function(self)
      local model = require("models.OssStatsDiamond")
      local d = date(false)
      local page = model.getPage(d:fmt("%F"))
      
      if page then
        self.StatsPage = page
      end
      
      return { render = "stats.UserDiamond", layout = false }
    end,
    
  }))

  app:match("stats_onlinesnapshot", "/StatsUserOnlineSnapshot", respond_to({
    --
    before = function(self)
      auth(self, "any", self.route_name)
    end,
    
    --
    GET = function(self)
      local model = require("models.OssStatsOnlineSnapshot")
      local d = date(false)
      local data = model.getData(d:fmt("%F %T"))
      
      if data then
        self.StatsData = data
      end
      
      return { render = "stats.UserOnlineSnapshot", layout = false }
    end,

    --
    POST = capture_errors(function(self)
      validate.assert_valid(self.params, {
        { "QueryTime", optional=true, min_length = 16, max_length = 22 },
      })
    
      local model = require("models.OssStatsOnlineSnapshot")
      local d = date(false)

      -- check QueryTime
      if self.params.QueryTime ~= "" then
        d = date(self.params.QueryTime)
      end
      
      local data = model.getData(d:fmt("%F %T"))
      
      if data and self.session.user then
        self.success_infos = { "Success" }
        self.StatsData = data
        return { render = "stats.UserOnlineSnapshot", layout = false }
      else
        --assert_error(false, "xxxx错误!")
      end
    end,

    -- on_error
    function(self)
        return { render = "stats.UserOnlineSnapshot", layout = false }
    end)
    
  }))

app:match("stats_retention", "/StatsUserRetention", respond_to({
    --
    before = function(self)
      auth(self, "any", self.route_name)
    end,
    
    --
    GET = function(self)
      local model = require("models.OssStatsRetention")
      local d = date(false)
      
      local page = model.getPage(d:fmt("%F"))
      
      if page then
        self.StatsPage = page
      end
      
      return { render = "stats.UserRetention", layout = false }
    end,

    --
    POST = capture_errors(function(self)
      validate.assert_valid(self.params, {
        { "QueryTime", optional=true, min_length = 10, max_length = 10 },
      })
    
      local model = require("models.OssStatsRetention")
      local d = date(false)

      -- check QueryTime
      if self.params.QueryTime ~= "" then
        d = date(self.params.QueryTime)
      end
      
      local page = model.getPage(d:fmt("%F"))
      
      if page then
        self.success_infos = { "Success" }
        self.StatsPage = page
      end
      
      return { render = "stats.UserRetention", layout = false }
    end,

    -- on_error
    function(self)
        return { render = "stats.UserRetention", layout = false }
    end)
    
  }))
end