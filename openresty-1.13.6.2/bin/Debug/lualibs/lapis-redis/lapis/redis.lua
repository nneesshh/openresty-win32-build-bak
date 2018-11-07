local redis
if ngx then
  redis = require("resty.redis")
end
local redis_down = nil
local connect_redis
connect_redis = function(opts)
  if "table" ~= type(opts) then
    return nil, "wrong options type: it must be a table!"
  end
  local r = redis:new()
  local ok, err = r:connect(opts.host, opts.port)
  if not ok then
    redis_down = ngx.time()
    return nil, err
  end
  -- "reused times == 1" means new created connection
  local count
  count, err = r:get_reused_times()
  if 0 == count then
    -- need auth
    if "string" == type(opts.password) then
      ok, err = r:auth(opts.password)
      if not ok then
        return nil, err
      end
    end
  end
  return r
end
local get_redis
get_redis = function(opts)
  if not (redis) then
    return nil, "missing redis library"
  end
  if redis_down and redis_down + 60 > ngx.time() then
    return nil, "redis down"
  end
  ngx.ctx.redis = ngx.ctx.redis or {}
  opts.pool = opts.pool or opts.host .. ":" .. opts.port
  local r = ngx.ctx.redis[opts.pool]
  if not (r) then
    local after_dispatch
    do
      local _obj_0 = require("lapis.nginx.context")
      after_dispatch = _obj_0.after_dispatch
    end
    local err
    r, err = connect_redis(opts)
    if not (r) then
      return nil, err
    end
    ngx.ctx.redis[opts.pool] = r
    after_dispatch(function()
      -- put it into the connection pool of size 100, with 60 seconds max idle time
      return r:set_keepalive(60000, 100)
    end)
  end
  return r
end
local redis_cache
redis_cache = function(prefix, opts)
  return function(req)
    local r = get_redis(opts)
    return {
      get = function(self, key)
        if not (r) then
          return 
        end
        do
          local out = r:get(tostring(prefix) .. ":" .. tostring(key))
          if out == ngx.null then
            return nil
          end
          return out
        end
      end,
      set = function(self, key, content, expire)
        if not (r) then
          return 
        end
        local r_key = tostring(prefix) .. ":" .. tostring(key)
        return r:setex(r_key, expire, content)
      end
    }
  end
end
local function is_null(res)
    if type(res) == "table" then
        for k,v in pairs(res) do
            if v ~= ngx.null then
                return false
            end
        end
        return true
    elseif res == ngx.null then
        return true
    elseif res == nil then
        return true
    end

    return false
end
return {
  get_redis = get_redis,
  redis_cache = redis_cache,
  is_null = is_null,
  auth = auth,
}
