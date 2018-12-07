package.path = package.path .. ";./?.lua;./lua/?.lua;./lua/?/init.lua;./lualibs/?.lua;./lualibs/?/init.lua;./src/?.lua;./src/?/init.lua"
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

-- protobuf
--package.path = package.path .. ";./lualibs/protobuf/?.lua"
--package.path = package.path .. ";./lua/proto_pb/?.lua"
--require("test_web")
--require("test_protodb")

--]]
local lapis = require("lapis")
local lapis_serve = lapis.serve
lapis_serve("app")
--[[]]