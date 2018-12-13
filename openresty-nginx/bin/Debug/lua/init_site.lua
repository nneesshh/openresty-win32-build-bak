local delay = 60  -- in seconds
local log = ngx.log
local ERR = ngx.ERR

package.path = package.path .. ";./lualibs/lua-resty-redis-0.26/lib/?.lua"
local iredis = require("utils.redis_iresty")

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