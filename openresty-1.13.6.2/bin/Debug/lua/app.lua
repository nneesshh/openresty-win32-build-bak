-- app.lua
local lapis = require("lapis")
local app = lapis.Application()

app:enable("etlua")
app:before_filter(function(self)

  print("got request: ", self.route_name)
  
  for k, v in pairs(self.params) do
    print(k, v)
  end
end)

require("controllers")(app)

return app