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
  app:match("admin_game_announcement", "/AdminGameAnnouncement", respond_to({
    --
    before = function(self)
      auth(self, "any", self.route_name)
    end,
    
    GET = function(self)
      local GameAnnouncement = require("models.GameAnnouncement")
      local gameAnnouncementList = GameAnnouncement.getAll()
      
      if #gameAnnouncementList > 0 then
        self.CurrentGameAnnouncement = gameAnnouncementList[1]
      end

      return { render = "admin.GameAnnouncement", layout = false }
    end,

  }))

  app:match("admin_game_announcement_create", "/AdminGameAnnouncement/Create", respond_to({
    --
    before = function(self)
      auth(self, "any", self.route_name)
    end,
    
    GET = function(self)
      --
      return { render = "admin.GameAnnouncementCreate", layout = false }
    end,

    POST = capture_errors(function(self)
      validate.assert_valid(self.params, {
        { "DeadlineTime", exists = true, min_length = 16, max_length = 22 },
        { "Content", exists = true, min_length = 2, max_length = 4096 },
      })
      
      local GameAnnouncement = require("models.GameAnnouncement")
      
      local obj = GameAnnouncement.create(self.params.DeadlineTime, self.params.Content)
      if obj and self.session.user then
        return { redirect_to = self:url_for("admin_game_announcement") }
      else
        --assert_error(false, "xxxx错误!")
      end
    end,
    -- on_error
    function(self)
        return { render = "admin.GameAnnouncementCreate", layout = false }
    end)
  }))

end