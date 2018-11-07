require("appsettings")
require('mobdebug').start('192.168.1.110') --<-- only insert this line

--require("test_web")
--require("test_protodb")

--[[]]
local lapis = require("lapis")
local lapis_serve = lapis.serve
lapis_serve("app")
--[[]]