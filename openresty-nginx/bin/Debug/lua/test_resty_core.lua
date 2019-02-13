package.cpath = package.cpath .. ";./?.dll;./clibs/?.dll"
package.path = package.path .. ";./lualibs/lua-resty-core-0.1.16rc3/lib/?.lua"

ngx = {
    config = {
        subsystem = 'stream',
        ngx_lua_version = 6
    },


}

require "resty.core.regex"
