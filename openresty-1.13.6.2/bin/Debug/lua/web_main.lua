require("appsettings")
require('mobdebug').start('127.0.0.1') --<-- only insert this line

--require("test_web")

--[[]]
local lapis = require("lapis")
local lapis_serve = lapis.serve
lapis_serve("app")
--[[]]