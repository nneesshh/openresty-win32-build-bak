-- Localize
local cwd = (...):gsub('%.[^%.]+$', '') .. "."

local lapis = require("lapis")
local appconfig = require("appconfig")
local config = appconfig.getConfig()
local respond_to = require("lapis.application").respond_to

local auth = require(cwd .. "authorize")

return function(app)
  app:match("login", "/login", respond_to({
    --
    before = function(self)
      self.user = Users:find(self.params.id)
      if not self.user then
        self:write({"Not Found", status = 404})
      end
    end,
    
    GET = function(self)
      return "Edit account " .. self.user.name
    end,
    
    POST = function(self)
      self.user:update(self.params.user)
      return { redirect_to = self:url_for("index") }
    end
  }))

end