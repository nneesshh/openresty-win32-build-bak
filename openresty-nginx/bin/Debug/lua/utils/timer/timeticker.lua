local math_random = math.random
local math_min = math.min
local math_max = math.max
local math_pi = math.pi
local math_sin = math.sin
local math_cos = math.cos
local math_asin = math.asin
local math_sqrt = math.sqrt

local type, pcall, setmetatable, coroutine, assert = type, pcall, setmetatable, coroutine, assert
local pairs, ipairs = pairs, ipairs
local unpack = unpack or table.unpack

local cwd = (...):gsub("%.[^%.]+$", "") .. "."
--[[ pure lua uuid ]]
local luauuid = require(cwd .. "luuid")
luauuid.seed()
--[[]]
local timermanager = require(cwd .. "timermanager")
local wheel = timermanager._wheel

local _M = {}
local mt = {__index = _M}

function _M.new(name)
    local self = {
        name = name or "timeticker",
        timers = {}
    }
    return setmetatable(self, mt)
end

local function _UUID()
    return luauuid()
end

local function random(min, max)
    local min, max = min or 0, max or 1
    return (min > max and (math_random() * (min - max) + max)) or (math_random() * (max - min) + min)
end

-- The after function will execute an action after a given amount of time
function _M:after(delay, action, tag)
    tag = tag or _UUID()
    self:cancel(tag)

    --
    local timer = {type = "after", wheelid = false, delay = self:__getResolvedDelay(delay), action = action}

    local cb = function(arg, wnow)
        local timer = arg.timers[arg.tag]
        timer.action()
        --
        arg.timers[arg.tag] = nil
    end

    local cbarg = {
        ticker = self,
        timers = self.timers,
        tag = tag,
        cb = cb
    }

    --
    local expired = delay
    timer.wheelid = wheel:set(expired, cb, cbarg)
    self.timers[tag] = timer
    return tag
end

-- The every function will execute an action repeatedly at an interval
function _M:every(delay, action, count, over, tag)
    if type(count) == "string" then
        tag, count = count, 0
    elseif type(count) == "number" and type(over) == "string" then
        tag, over = over, nil
    else
        tag = tag or _UUID()
    end
    self:cancel(tag)

    --
    local timer = {
        type = "every",
        wheelid = false,
        any_delay = delay,
        delay = self:__getResolvedDelay(delay),
        action = action,
        counter = 0,
        count = count or 0,
        action_over = over or function()
            end
    }

    local cb = function(arg, wnow)
        local timer = arg.timers[arg.tag]
        timer.action()
        
        --
        timer.delay = self:__getResolvedDelay(timer.any_delay)
        if timer.count > 0 then
            timer.counter = timer.counter + 1
            if timer.counter >= timer.count then
                timer.over()
                arg.timers[arg.tag] = nil
                return
            end
        end

        -- schedule next
        local expired = timer.delay
        timer.wheelid = wheel:set(expired, arg.cb, arg, wnow)
    end

    local cbarg = {
        ticker = self,
        timers = self.timers,
        tag = tag,
        cb = cb
    }

    --
    local expired = delay
    timer.wheelid = wheel:set(expired, cb, cbarg)
    self.timers[tag] = timer
    return tag
end

function _M:during(delay, action, over, tag)
    if type(over) == "string" then
        tag, over = over, nil
    else
        tag = tag or _UUID()
    end

    self:cancel(tag)

    --
    local timer = {
        type = "during",
        wheelid = false,
        starttime = false,
        delay = self:__getResolvedDelay(delay),
        action = action,
        over = over or function()
            end
    }

    local cb = function(arg, wnow)
        local timer = arg.timers[arg.tag]
        timer.action()

        local elapsed = wnow - timer.starttime
        if elapsed >= timer.delay then
            timer.over()
            arg.timers[arg.tag] = nil
            return
        end

        -- schedule next
        local expired = 0 -- expire_in=0 means expired at next frame
        timer.wheelid = wheel:set(expired, arg.cb, arg, wnow)
    end

    local cbarg = {
        ticker = self,
        timers = self.timers,
        tag = tag,
        cb = cb,
    }

    --
    local expired = 0 -- expire_in=0 means expired at next frame
    timer.wheelid, timer.starttime = wheel:set(expired, cb, cbarg)
    self.timers[tag] = timer
    return tag
end

function _M:script(f)
    local co = coroutine.wrap(f)
    co(
        function(t)
            self:after(t, co)
            coroutine.yield()
        end
    )
end

function _M:tween(delay, subject, target, method, over, tag, ...)
    if type(over) == "string" then
        tag, over = over, nil
    else
        tag = tag or _UUID()
    end

    self:cancel(tag)

    --
    local timer = {
        type = "tween",
        wheelid = false,
        starttime = false,
        delay = self:__getResolvedDelay(delay),
        subject = subject,
        target = target,
        method = method,
        over = over or function()
            end,
        args = {...},
        last_s = 0,
        payload = self:__tweenCollectPayload(subject, target, {})
    }

     local cb = function(arg, wnow)
        local timer = arg.timers[arg.tag]

        local elapsed = wnow - timer.starttime
        local s = arg.ticker:__tween(timer.method, math_min(1, elapsed / timer.delay), unpack(timer.args or {}))
        local ds = s - timer.last_s
        timer.last_s = s
        for _, info in ipairs(timer.payload) do
            local ref, key, delta = unpack(info)
            ref[key] = ref[key] + delta * ds
        end

        if elapsed >= timer.delay then
            timer.over()
            arg.timers[arg.tag] = nil
            return
        end

        -- schedule next
        local expired = 0 -- expire_in=0 means expired at next frame
        timer.wheelid = wheel:set(expired, arg.cb, arg, wnow)
    end

    local cbarg = {
        ticker = self,
        timers = self.timers,
        tag = tag,
        cb = cb
    }

    --
    local expired = 0 -- expire_in=0 means expired at next frame
    timer.wheelid, timer.starttime = wheel:set(expired, cb, cbarg)
    self.timers[tag] = timer
    return tag
end

function _M:cancel(tag)
    local timer = self.timers[tag]
    if timer then
        wheel.cancel(timer.wheelid)
        self.timers[tag] = nil
    end
end

function _M:destroy()
    for tag, timer in pairs(self.timers) do
        wheel.cancel(timer.wheelid)
        self.timers[tag] = nil
    end
    self.timers = {}
end

function _M:getTime(tag)
    return self.timers[tag].starttime, self.timers[tag].delay
end

function _M:__getResolvedDelay(delay)
    if type(delay) == "number" then
        return delay
    elseif type(delay) == "table" then
        return random(delay[1], delay[2])
    end
end

local t = {}
t.out = function(f)
    return function(s, ...)
        return 1 - f(1 - s, ...)
    end
end
t.chain = function(f1, f2)
    return function(s, ...)
        return (s < 0.5 and f1(2 * s, ...) or 1 + f2(2 * s - 1, ...)) * 0.5
    end
end
t.linear = function(s)
    return s
end
t.quad = function(s)
    return s * s
end
t.cubic = function(s)
    return s * s * s
end
t.quart = function(s)
    return s * s * s * s
end
t.quint = function(s)
    return s * s * s * s * s
end
t.sine = function(s)
    return 1 - math_cos(s * math_pi / 2)
end
t.expo = function(s)
    return 2 ^ (10 * (s - 1))
end
t.circ = function(s)
    return 1 - math_sqrt(1 - s * s)
end
t.back = function(s, bounciness)
    bounciness = bounciness or 1.70158
    return s * s * ((bounciness + 1) * s - bounciness)
end
t.bounce = function(s)
    local a, b = 7.5625, 1 / 2.75
    return math_min(
        a * s ^ 2,
        a * (s - 1.5 * b) ^ 2 + 0.75,
        a * (s - 2.25 * b) ^ 2 + 0.9375,
        a * (s - 2.625 * b) ^ 2 + 0.984375
    )
end
t.elastic = function(s, amp, period)
    amp, period = amp and math_max(1, amp) or 1, period or 0.3
    return (-amp * math_sin(2 * math_pi / period * (s - 1) - math_asin(1 / amp))) * 2 ^ (10 * (s - 1))
end

function _M:__tween(method, ...)
    if method == "linear" then
        return t.linear(...)
    elseif method:find("in%-out%-") then
        return t.chain(t[method:sub(8, -1)], t.out(t[method:sub(8, -1)]))(...)
    elseif method:find("out%-in%-") then
        return t.chain(t.out(t[method:sub(8, -1)]), t[method:sub(8, -1)])(...)
    elseif method:find("out%-") then
        return t.out(t[method:sub(5, -1)])(...)
    elseif method:find("in%-") then
        return t[method:sub(4, -1)](...)
    end
end

function _M:__tweenCollectPayload(subject, target, out)
    for k, v in pairs(target) do
        local ref = subject[k]
        assert(type(v) == type(ref), 'Type mismatch in field "' .. k .. '".')
        if type(v) == "table" then
            self:__tweenCollectPayload(ref, v, out)
        else
            local ok, delta =
                pcall(
                function()
                    return (v - ref) * 1
                end
            )
            assert(ok, 'Field "' .. k .. '" does not support arithmetic operations.')
            out[#out + 1] = {subject, k, delta}
        end
    end
    return out
end

--return setmetatable({}, {__call = function(_, ...) return _M.new(...) end})
return _M
