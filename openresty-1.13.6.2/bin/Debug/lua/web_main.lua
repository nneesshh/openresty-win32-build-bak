require("appsettings")
require('mobdebug').start('192.168.1.110') --<-- only insert this line127.0.0.1

--require("test_web")

--[[]]
local lapis = require("lapis")
local lapis_serve = lapis.serve
lapis_serve("app")
--[[]]