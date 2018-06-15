local lapis = require("lapis")
local appconfig = require("appconfig")
local config = appconfig.get("my_umb")

local app = lapis.Application()
local respond_to = require("lapis.application").respond_to

-- Localize
local cwd = (...):gsub('%.[^%.]+$', '') .. "."
local auth = require(cwd .. "authorize")

app:match("index", "/", respond_to({
  before = nil, -- auth
  GET = function(self)
    return "Edit account " .. self.user.name
  end,
  POST = function(self)
    self.user:update(self.params.user)
    return { redirect_to = self:url_for("index") }
  end
}))

return app