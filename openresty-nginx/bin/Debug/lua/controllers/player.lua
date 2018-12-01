-- Localize
local cwd = (...):gsub('%.[^%.]+$', '') .. "."
local ostime = os.time
local date = require("date")

local appconfig = require("appconfig")
local config = appconfig.getConfig()

local app_helpers = require("lapis.application")
local respond_to = app_helpers.respond_to
local capture_errors = app_helpers.capture_errors
local assert_error = app_helpers.assert_error

local validate = require("lapis.validate")

local auth = require(cwd .. "authorize")

return function(app)
  app:match("player_manage", "/PlayerManage", respond_to({
    --
    before = function(self)
      auth(self, "any", self.route_name)
    end,
    
    --
    GET = function(self)
      return { render = "player.Manage", layout = false }
    end,
    
  }))

  app:match("player_manager_query_online", "/PlayerManage/QueryOnline", respond_to({
    --
    before = function(self)
      auth(self, "any", self.route_name)
    end,
    
    GET = function(self)
      --
      return { render = "player.QueryOnline", layout = false }
    end,

    --
    POST = capture_errors(function(self)
      validate.assert_valid(self.params, {
        { "UserId", exists = true, min_length = 2, max_length = 50 },
      })
    
      local PlayerManage = require("models.PlayerManage")
      
      -- check userid 
      local bExist = PlayerManage.checkUserId(self.params.UserId)
      if not bExist then
        assert_error(false, "UserId(" .. tostring(self.params.UserId) ..  ") not exist!!!")
      end

      local data = PlayerManage.getPlayerOnline(self.params.UserId)
      
      if data and self.session.user then
        self.success_infos = { "Success" }
        self.PlayerData = data
        return { render = "player.QueryOnline", layout = false }
      else
        --assert_error(false, "xxxx错误!")
      end
    end,
    -- on_error
    function(self)
      return { render = "player.QueryOnline", layout = false }
  end)
    
  }))

  app:match("player_manager_query_charge", "/PlayerManage/QueryCharge", respond_to({
    --
    before = function(self)
      auth(self, "any", self.route_name)
    end,

    GET = function(self)
      --
      return { render = "player.QueryCharge", layout = false }
    end,
    
    --
    POST = capture_errors(function(self)
      validate.assert_valid(self.params, {
        { "UserId", exists = true, min_length = 2, max_length = 50 },
        { "BeginDate", optional=true, min_length = 10, max_length = 22 },
        { "EndDate", optional=true, min_length = 10, max_length = 22 },
      })
    
      local PlayerManage = require("models.PlayerManage")
      
      -- check userid 
      local bExist = PlayerManage.checkUserId(self.params.UserId)
      if not bExist then
        assert_error(false, "UserId(" .. tostring(self.params.UserId) ..  ") not exist!!!")
      end

      local d1 = date(false)

      -- check begin_time
      local week_ago = date(d1):adddays(-7)
      local begin_time = week_ago:fmt("%F")
      if self.params.BeginDate and self.params.BeginDate ~= "" then
        local d2 = date(self.params.BeginDate)
        begin_time = d2:fmt("%F")
      end

      -- check end_time
      local end_time = d1:fmt("%F")
      if self.params.EndDate and self.params.EndDate ~= "" then
        local d2 = date(self.params.EndDate)
        end_time = d2:fmt("%F")
      end

      --
      local data = PlayerManage.getPlayerCharge(self.params.UserId, begin_time, end_time)
      
      if data and self.session.user then
        self.success_infos = { "Success" }
        self.PlayerData = data
        return { render = "player.QueryCharge", layout = false }
      else
        --assert_error(false, "xxxx错误!")
      end

    end,
    -- on_error
    function(self)
      return { render = "player.QueryCharge", layout = false }
  end)
  }))

end