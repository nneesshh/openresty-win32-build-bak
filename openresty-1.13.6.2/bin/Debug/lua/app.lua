-- app.lua
local lapis = require("lapis")
local app = lapis.Application()

app:enable("etlua")

require("controllers")(app)

return app