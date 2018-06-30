local delay = 60  -- in seconds
local log = ngx.log
local ERR = ngx.ERR

local iredis = require("utils.redis_iresty")

local init_site
local check

check = function(premature)
    --
    if not premature then
        -- do the health check or other routine work
        log(ERR, "mm test mm test")
    end

    --
    

end



if 0 == ngx.worker.id() then
    local ok, err = ngx.timer.every(delay, check)
    if not ok then
        log(ERR, "failed to create timer: ", err)
        return
    end
end