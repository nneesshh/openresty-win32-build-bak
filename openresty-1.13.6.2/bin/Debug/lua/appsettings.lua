-- common
package.path = package.path .. ";./lualibs/?.lua;./lualibs/?/init.lua;./lua/?.lua;./lua/?/init.lua"
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

--
require = require("utils.require").require
require("utils.functions")

local jituuid = require("resty.jit-uuid")
jituuid.seed()