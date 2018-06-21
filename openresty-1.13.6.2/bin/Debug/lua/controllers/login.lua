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
      auth(self, "any", self.route_name)
    end,
    
    GET = function(self)
      return { render = "login.index" }
    end,
    
    POST = function(self)
      
      local Users = require("models.Users")
      local user = Users.getByName(self.params.UserName)
      if user and user.UserName == self.params.UserName and user.Password == self.params.Password then
        local UserRoles = require("models.UserRoles")
        
        self.user = user.UserName
        self.role = user
        return { redirect_to = self:url_for("welcome") }
      else
        return { render = "login.index", { ErrorInfo = "用户名密码错误!" } }
      end
    end
  }))

end