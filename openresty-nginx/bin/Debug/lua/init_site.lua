local delay = 60  -- in seconds
local log = ngx.log
local ERR = ngx.ERR

--
require = require("utils.require").require

-- common
package.path = package.path .. ";./?.lua;./lua/?.lua;./lua/?/init.lua;./lualibs/?.lua;./lualibs/?/init.lua;./src/?.lua;./src/?/init.lua"
package.cpath = package.cpath .. ";./?.dll;./clibs/?.dll"

-- lapis
package.path = package.path .. ";./lualibs/lapis-1.7.0/?.lua;./lualibs/lapis-1.7.0/?/init.lua"
package.path = package.path .. ";./lualibs/loadkit-1.1.0/?.lua"
package.path = package.path .. ";./lualibs/etlua-1.3.0/?.lua"
package.path = package.path .. ";./lualibs/lapis-redis/?.lua"

-- resty: mysql, jit-uuid, redis, string
package.path = package.path .. ";./lualibs/lua-resty-mysql-0.21/lib/?.lua"
package.path = package.path .. ";./lualibs/lua-resty-jit-uuid-0.0.7/lib/?.lua"
package.path = package.path .. ";./lualibs/lua-resty-redis-0.26/lib/?.lua"
package.path = package.path .. ";./lualibs/lua-resty-string-0.11/lib/?.lua"

-- date
package.path = package.path .. ";./lualibs/luadate-2.1/?.lua"

-- protobuf
package.path = package.path .. ";./lualibs/protobuf/?.lua"
package.path = package.path .. ";./lua/proto_pb/?.lua"

-- redis
package.path = package.path .. ";./lualibs/lua-resty-redis-0.26/lib/?.lua"

local iredis = require("utils.redis_iresty")
require("utils.functions")
require("uuid")

--[[
package.path =
    package.path ..
    ";D:/www/_nneesshh_git/ZeroBraneStudio53/lualibs/?/?.lua;D:/www/_nneesshh_git/ZeroBraneStudio53/lualibs/?.lua"
package.cpath =
    package.cpath ..
    ";D:/www/_nneesshh_git/ZeroBraneStudio53/bin/?.dll;D:/www/_nneesshh_git/ZeroBraneStudio53/bin/clibs/?.dll"

require('mobdebug').start('192.168.1.110') --<-- only insert this line
--]]

-- protobuf
--package.path = package.path .. ";./lualibs/protobuf/?.lua"
--package.path = package.path .. ";./lua/proto_pb/?.lua"

local init_site
local func_check_per_min

func_check_per_min = function(premature)
    --
    if not premature then
        -- do the health check or other routine work
        log(ERR, "do the health check or other routine work")
    end

    --
    

end



if 0 == ngx.worker.id() then
    local ok, err = ngx.timer.every(delay, func_check_per_min)
    if not ok then
        log(ERR, "failed to create timer: ", err)
        return
    end
end