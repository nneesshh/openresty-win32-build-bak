local math_random = math.random
local math_min = math.min
local math_max = math.max
local math_pi = math.pi
local math_sin = math.sin
local math_cos = math.cos
local math_asin = math.asin
local math_sqrt = math.sqrt

local os = os
local type, pcall, setmetatable, coroutine, assert = type, pcall, setmetatable, coroutine, assert
local pairs, ipairs = pairs, ipairs
local unpack = unpack or table.unpack
local str_find = string.find
local str_sub = string.sub
local str_format = string.format
local tbl_insert = table.insert
local tonumber = tonumber
local tostring = tostring

local print = print
local error = error

local cwd = (...):gsub("%.[^%.]+$", "") .. "."
--[[ pure lua uuid ]]
local luauuid = require(cwd .. "luuid")
luauuid.seed()
--[[]]
local timermanager = require(cwd .. "timermanager")
local wheel = timermanager._wheel

local _M = {}
local mt = {__index = _M}

local TIMESLICER_STATE_IDLE = 1
local TIMESLICER_STATE_TICKING = 2

function _M.new(name, format)
    local self = {
        name = name or "timeslicer",
        format = format,
        timer = {wheelid = false},
        slicePointer = 0,
        cycle = false,
        beginCb = false,
        endCb = false,
        state = TIMESLICER_STATE_IDLE
    }
    return setmetatable(self, mt)
end

local function __reset(self, tmCheck)
    local slicePointer, cycle, awake, follow = self.format:findSlicePointerByTime(tmCheck)
    self.slicePointer = slicePointer
    self.cycle = cycle
end

local function __fireBeginEvent(self, slice, tmNow)
    --
    local cb = function(arg, wnow)
        local slicer = arg.slicer
        slicer.state = TIMESLICER_STATE_IDLE
        slicer:onBegin(slice, wnow)
    end

    local cbarg = {
        slicer = self,
        cb = cb
    }

    --
    self.state = TIMESLICER_STATE_TICKING

    --
    local beginTime = self:getSliceBeginTimeByCycle(slice, self.cycle)
    local expired = beginTime - tmNow
    return wheel:set(expired, cb, cbarg)
end

local function __fireEndEvent(self, slice, tmNow)
    --
    local cb = function(arg, wnow)
        local slicer = arg.slicer
        slicer.state = TIMESLICER_STATE_IDLE
        slicer:onEnd(slice, wnow)
    end

    local cbarg = {
        slicer = self,
        cb = cb
    }

    --
    self.state = TIMESLICER_STATE_TICKING

    --
    local endTime = self:getSliceEndTimeByCycle(slice, self.cycle)
    local expired = endTime - tmNow
    return wheel:set(expired, cb, cbarg)
end

local function __nextSlicePointer(self)
    return self.format:nextSlicePointer(self.slicePointer, self.cycle)
end

local function __clearEvent(self)
    if self.timer.wheelid then
        wheel.cancel(self.timer.wheelid)
    end
end

--
function _M:startTick(beginCb, endCb)
    local tmNow = os.time()

    self.beginCb = beginCb
    self.endCb = endCb

    --
    if self:isTicking() then
        local desc = str_format("timer(%s) is already in ticking!", self.name)
        print(desc)
        --error(desc)
    end

    --
    if self.format and self.format:getSliceSize() > 0 then
        __reset(self, tmNow)

        if self.slicePointer > 0 then
            local slice = self.format:getSliceAt(self.slicePointer)
            self.timer.wheelid = __fireBeginEvent(self, slice, tmNow)
            return
        end

        --warning -- invalid format
        local desc =
            str_format("\n[timeslicer:startTick()] name(%s), format is invalid, start tick failed!!!\n", self.name)
        print(desc)
        --error(desc)
    else
        -- warning -- empty slice list
        local desc =
            str_format("\n[timeslicer:startTick()] name(%s), slice list is empty, start tick failed!!!\n", self.name)
        print(desc)
        --error(desc)
    end
end

--
function _M:stopTick()
    if self:isTicking() then
        __clearEvent(self)

        --//
        self.state = TIMESLICER_STATE_IDLE
    end
end

--
function _M:isTicking()
    return TIMESLICER_STATE_TICKING == self.state
end

--
function _M:getSliceFormat()
    return self.format
end

-- return slice, cycle
function _M:getNowSlice()
    local tmNow = os.time()
    return self:getSliceByTime(tmNow)
end

--
function _M:getSliceByTime(tmCheck)
    local slice, cycle, awake, follow = self.format:allocateSlice(tmCheck)
    if awake then
        return slice
    end
end

--
function _M:getSliceBeginTime(slice, tmClue)
    if self:isTicking() then
        return self:getSliceBeginTimeByCycle(slice, self.cycle)
    end

    --
    if tmClue > 0 then
        -- find slice cycle
        local slicePointer, cycle, awake, follow = self.format:findSlicePointerByTime(tmClue)

        -- ignore awake-follow value, we just use cycle
        if slicePointer > 0 then
            return self:getSliceBeginTime(slice, cycle)
        end
    end

    return 0
end

--
function _M:getSliceBeginTimeByCycle(slice, cycle)
    return cycle.base + slice.begin_time
end

--
function _M:getSliceEndTime(slice, tmClue)
    if self:isTicking() then
        return self:getSliceEndTime(slice, self.cycle)
    end

    --
    if tmClue > 0 then
        -- find slice cycle
        local slicePointer, cycle, awake, follow = self.format:findSlicePointerByTime(tmClue)

        -- ignore awake-follow value, we just use cycle
        if slicePointer > 0 then
            return self:getSliceEndTime(slice, cycle)
        end
    end

    return 0
end

local function _getValidFormatEndTime(slice, TIME_MAX)
    return (0 == slice._end_time) and TIME_MAX or slice.end_time
end

--
function _M:getSliceEndTimeByCycle(slice, cycle)
    -- valid format end time
    local uEndTime = _getValidFormatEndTime(slice, cycle.timemax)
    return cycle.base + uEndTime
end

--
function _M:isTimeInSlicePeriod(tmCheck, slice, time_t, tmClue)
    if self:isTicking() then
        return self:isTimeInSlicePeriodByCycle(tmCheck, slice, self.cycle)
    end

    --
    if tmClue > 0 then
        -- find slice cycle
        local slicePointer, cycle, awake, follow = self.format:findSlicePointerByTime(tmClue)

        -- ignore awake-follow value, we just use cycle
        if slicePointer > 0 then
            return self:isTimeInSlicePeriodByCycle(tmCheck, slice, cycle)
        end
    end
    return false
end

--
function _M:isTimeInSlicePeriodByCycle(tmCheck, slice, cycle)
    return self:getSliceBeginTimeByCycle(slice, cycle) <= tmCheck and tmCheck < self:getSliceEndTime(slice, cycle)
end

--
function _M:onBegin(slice, tmNow)
    self:beginCb(slice)
    self.timer.wheelid = __fireEndEvent(self, slice, tmNow)
end

--
function _M:onEnd(slice, tmNow)
    self:endCb(slice)

    --
    self.slicePointer = __nextSlicePointer(self)

    -- next slice begin
    local sliceNext = self.format:getSliceAt(self.slicePointer)
    self.timer.wheelid = __fireBeginEvent(self, sliceNext, tmNow)
end

--return setmetatable({}, {__call = function(_, ...) return _M.new(...) end})
return _M
