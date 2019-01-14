--
package.path =
    package.path ..
    ";D:/www/_nneesshh_git/ZeroBraneStudio53/lualibs/?/?.lua;D:/www/_nneesshh_git/ZeroBraneStudio53/lualibs/?.lua"
package.cpath =
    package.cpath ..
    ";D:/www/_nneesshh_git/ZeroBraneStudio53/bin/?.dll;D:/www/_nneesshh_git/ZeroBraneStudio53/bin/clibs/?.dll"

require("mobdebug").start("192.168.1.110") -- <-- only insert this line
--[[]]
local redis_pass = require "redis.redis_pass"
pool =
    redis_pass:new(
    {
        ip = "127.0.0.1",
        port = "6379",
        auth = false
    }
)
pool:run()

--[[]]
