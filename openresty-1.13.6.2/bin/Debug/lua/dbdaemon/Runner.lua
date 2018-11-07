-- Localize
local cwd = (...):gsub('%.[^%.]+$', '') .. "."
local task_builder = require(cwd .. "TaskBuilder")

--
local delay = 60  -- in seconds
local log = ngx.log
local ERR = ngx.ERR -- ngx.STDERR , ngx.EMERG, ngx.ALERT, ngx.CRIT, ngx.ERR, ngx.WARN, ngx.NOTICE, ngx.INFO, ngx.DEBUG

local _M = {
    _tasks = false,
}

local function _init()
    require('mobdebug').start('192.168.1.110') --<-- only insert this line
  
    if _M._tasks then
        for _, task in pairs(_M._tasks) do
            task_builder.build(task)
        end
    end
end

local function _check(premature)
    log(ERR, "premature: ", premature)
    
    --
    if not premature then
        -- do the health check or other routine work
        log(ERR, "process: ")
    end
end

return setmetatable(_M, {
    __call = function(_, tasks)
        local ok, err      
        assert(_M == _)
        _M._tasks = tasks
        
        -- init timer
        ok, err = ngx.timer.at(0, _init)
        if not ok then
            log(ERR, "failed to create timer: ", err)
            return
        end
      
        -- check timer
        ok, err = ngx.timer.every(delay, _check)
        if not ok then
            log(ERR, "failed to create timer: ", err)
            return
        end
    end,
})