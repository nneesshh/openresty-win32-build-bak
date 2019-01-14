-- Localize
local cwd = (...):gsub("%.[^%.]+$", "") .. "."

-- app.lua
local date = require("date")
local lapis = require("lapis")
local app = lapis.Application()

-- configure cookie settings:
app.cookie_attributes = function(self)
  -- 1 day to expire
  local expires = date(true):adddays(1):fmt("${http}")
  return "Expires=" .. expires .. "; Path=/; HttpOnly"
end

app:enable("etlua")
app.layout = require(cwd .. "views.shared.Layout")

app:before_filter(
  function(self)
    print("got request: ", self.route_name)

    for k, v in pairs(self.params) do
      print(k, "=", v)
    end
  end
)

require(cwd .. "controllers")(app)

return app
