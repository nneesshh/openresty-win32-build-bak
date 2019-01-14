local Model = require("lapis.db.model").Model
local lapis_redis = require("lapis.redis")

local log = ngx.log
local ERR = ngx.ERR -- ngx.STDERR , ngx.EMERG, ngx.ALERT, ngx.CRIT, ngx.ERR, ngx.WARN, ngx.NOTICE, ngx.INFO, ngx.DEBUG

local _M = {
    _tasks = false,
}

local function _createIdHash(moduleName, mainId, subid)
    return moduleName .. ":" .. mainId .. ":" .. subid .. ":H"
end

local function _createIdSetOfAllKeys(moduleName, mainId, subid)
    return moduleName .. ":" .. mainId .. ":" .. subid .. ":A_S"
end

local function _createIdSetOfDirtyKeys(moduleName, mainId, subid)
    return moduleName .. ":" .. mainId .. ":" .. subid .. ":D_S"
end

function _M.build(task)
    local db_opts = task.getDbOptions()
    local r_opts = task.getRedisOptions()

    -- create db entity
    for _, e in ipairs(task._entities) do
        if not e._db_entity and e.tbl then
            e._db_entity = Model:extend(db_opts, e.tbl, {
                primary_key = e.key
            })
        end
    end
    
    -- preload
    if task._preload then 
        local r = lapis_redis.get_redis(r_opts)
      
        for _, e in ipairs(task._entities) do
            dump("+++++++++++++++++++++++++++++++")

            if e._db_entity then
                local result = e._db_entity:select("WHERE 1=1", { fields = "*" })
                if result then
                  
                    for i, row in ipairs(result) do
                        local rkey = _createIdHash(task._module_name, e.tbl, row[e.key], "1")
                    
                        dump("rkey=" .. rkey)
                        lapis_redis.redis_cache(rkey, row)
                    end
                end
            end
            
            dump("-----------------------------")
        end
    end
    
end

return _M