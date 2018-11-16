package.path = package.path .. ";./?.lua;./lua/?.lua;./lua/?/init.lua;./src/?.lua;./src/?/init.lua;./lua/protobuf/?.lua;./lua/proto_pb/?.lua"
package.cpath = package.cpath .. ";./?.dll;./clibs/?.dll"

--[[
package.path =
    package.path ..
    ";D:/www/_nneesshh_git/ZeroBraneStudio53/lualibs/?/?.lua;D:/www/_nneesshh_git/ZeroBraneStudio53/lualibs/?.lua"
package.cpath =
    package.cpath ..
    ";D:/www/_nneesshh_git/ZeroBraneStudio53/bin/?.dll;D:/www/_nneesshh_git/ZeroBraneStudio53/bin/clibs/?.dll"

require('mobdebug').start('192.168.1.110') --<-- only insert this line
--]]

require("appsettings")

--require("test_web")
--require("test_protodb")

--[[]]
local lapis = require("lapis")
local lapis_serve = lapis.serve
lapis_serve("app")
--[[]]