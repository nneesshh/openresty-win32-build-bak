local math_random = math.random
local math_min = math.min
local math_max = math.max
local math_pi = math.pi
local math_sin = math.sin
local math_cos = math.cos
local math_asin = math.asin
local math_sqrt = math.sqrt
local math_fmod = math.fmod
local math_floor = math.floor
local math_ceil = math.ceil

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

local cwd = (...):gsub("%.[^%.]+$", "") .. "."

local _M = {}
local mt = {__index = _M}

local MIN_SECONDS = 60
local HOUR_SECONDS = 3600
local DAY_SECONDS = 86400
local WEEK_SECONDS = 604800

local function __split(str, sep)
    local ret = {}
    local pos = 1
    local b = str_find(str, sep, pos)
    while b do
        tbl_insert(ret, str_sub(str, pos, b - 1))
        pos = b + 1
        b = str_find(str, sep, pos)
    end
    tbl_insert(ret, str_sub(str, pos, -1))
    return ret
end

local function __getValidFormatEndTime(slice, TIME_MAX)
    return (0 == slice.end_time) and TIME_MAX or slice.end_time
end

local function __isBetweenPeriod(tmCheck, tmBase, beginTime, endTime)
    return tmBase + beginTime <= tmCheck and tmCheck < tmBase + endTime
end

function _M.newDaily()
    --
    local self = {
        nextId = 1,
        sliceList = {}
    }

    --
    self.rollCycleBase = function(self, cycle)
        local CYCLE_TIME = DAY_SECONDS
        cycle.base = cycle.base + CYCLE_TIME
    end

    --
    self.resetCycle = function(self, tmCheck, cycle)
        -- day
        local tab = os.date("*t", tmCheck)
        local tmDay = os.time({day = tab.day, month = tab.month, year = tab.year, hour = 0, minute = 0, second = 0})
        local CYCLE_TIME = DAY_SECONDS

        --
        local tmBase = tmDay
        local uTimeMin = CYCLE_TIME
        local uTimeMax = 0
        local uEndTime = 0

        -- check time slice min and slice max
        for i, v in ipairs(self.sliceList) do
            local slice = v
            -- valid format end time
            uEndTime = __getValidFormatEndTime(slice, CYCLE_TIME)

            uTimeMin = (slice.begin_time < uTimeMin) and slice.begin_time or uTimeMin
            uTimeMax = (uEndTime > uTimeMax) and uEndTime or uTimeMax
        end

        -- adjust bound -- uTimeMax should be greater than CYCLE_TIME at least
        uTimeMin = math_min(uTimeMin, CYCLE_TIME)
        uTimeMax = math_max(uTimeMax, uTimeMin + CYCLE_TIME)

        --
        if not __isBetweenPeriod(tmCheck, tmBase, uTimeMin, uTimeMax) then
            -- use pre
            tmBase = tmBase - CYCLE_TIME
        end

        --
        cycle.base = tmBase
        cycle.timemin = uTimeMin
        cycle.timemax = uTimeMax
    end

    return setmetatable(self, mt)
end

function _M.newWeekly()
    --
    local self = {
        nextId = 1,
        sliceList = {}
    }

    --
    self.rollCycleBase = function(self, cycle)
        local CYCLE_TIME = WEEK_SECONDS
        cycle.base = cycle.base + CYCLE_TIME
    end

    --
    self.resetCycle = function(self, tmCheck, cycle)
        -- week day
        local tab = os.date("*t", tmCheck)
        local w = tab.wday - 1
        local tmWeekDay = os.time({day = tab.day - w, month = tab.month, year = tab.year, hour = 0, minute = 0, second = 0})
        local CYCLE_TIME = WEEK_SECONDS

        --
        local tmBase = tmWeekDay
        local uTimeMin = CYCLE_TIME
        local uTimeMax = 0
        local uEndTime = 0

        -- check time slice min and slice max
        for i, v in ipairs(self.sliceList) do
            local slice = v
            -- valid format end time
            uEndTime = __getValidFormatEndTime(slice, CYCLE_TIME)

            uTimeMin = (slice.begin_time < uTimeMin) and slice.begin_time or uTimeMin
            uTimeMax = (uEndTime > uTimeMax) and uEndTime or uTimeMax
        end

        -- adjust bound -- uTimeMax should be greater than CYCLE_TIME at least
        uTimeMin = math_min(uTimeMin, CYCLE_TIME)
        uTimeMax = math_max(uTimeMax, uTimeMin + CYCLE_TIME)

        --
        if not __isBetweenPeriod(tmCheck, tmBase, uTimeMin, uTimeMax) then
            -- use pre
            tmBase = tmBase - CYCLE_TIME
        end

        --
        cycle.base = tmBase
        cycle.timemin = uTimeMin
        cycle.timemax = uTimeMax
    end

    return setmetatable(self, mt)
end

function _M.newMonthly()
    --
    local self = {
        nextId = 1,
        sliceList = {}
    }

    --
    self.rollCycleBase = function(self, cycle)
        -- timemax is in next cycle, so just check it
        local tmCheck = cycle.base + cycle.timemax
		self:resetCycle(tmCheck, cycle)
    end

    --
    self.resetCycle = function(self, tmCheck, cycle)
        -- month day
        local tab = os.date("*t", tmCheck)
        local tmMonthDay = os.time({day = 1, month = tab.month, year = tab.year, hour = 0, minute = 0, second = 0})
        local tmMonthDayPre = os.time({day = 1, month = tab.month - 1, year = tab.year, hour = 0, minute = 0, second = 0})
        local tmMonthDayPost = os.time({day = 1, month = tab.month + 1, year = tab.year, hour = 0, minute = 0, second = 0})

        --[[
        print(os.date("%Y-%m-%d %H:%M:%S", tmMonthDay))
        print(os.date("%Y-%m-%d %H:%M:%S", tmMonthDayPre))
        print(os.date("%Y-%m-%d %H:%M:%S", tmMonthDayPost))
        --[[]]
        local CYCLE_TIME = tmMonthDayPost - tmMonthDay

        --
        local tmBase = tmMonthDay
        local uTimeMin = CYCLE_TIME
        local uTimeMax = 0
        local uEndTime = 0

        -- check time slice min and slice max
        for i, v in ipairs(self.sliceList) do
            local slice = v
            -- valid format end time
            uEndTime = __getValidFormatEndTime(slice, CYCLE_TIME)

            uTimeMin = (slice.begin_time < uTimeMin) and slice.begin_time or uTimeMin
            uTimeMax = (uEndTime > uTimeMax) and uEndTime or uTimeMax
        end

        -- adjust bound -- uTimeMax should be greater than CYCLE_TIME at least
        uTimeMin = math_min(uTimeMin, CYCLE_TIME)
        uTimeMax = math_max(uTimeMax, uTimeMin + CYCLE_TIME)

        --
        if not __isBetweenPeriod(tmCheck, tmBase, uTimeMin, uTimeMax) then
            -- use pre
            tmBase = tmMonthDayPre
        end

        --
        cycle.base = tmBase
        cycle.timemin = uTimeMin
        cycle.timemax = uTimeMax
    end

    return setmetatable(self, mt)
end

local function __addFormat(self, beginTime, endTime)

    assert(type(beginTime) == "string")

    local nextId = self.nextId
    self.nextId = self.nextId + 1
    local slice = {
        id = nextId,
        enable = true,
        desc = false,
        begin_time = 0,
        begin_time_desc = "00:00",
        end_time = 0,
        end_time_desc = "?"
    }

    -- check begin time
    local ret = __split(beginTime, ":")
    if #ret >= 2 then
        slice.begin_time = tonumber(ret[1]) * HOUR_SECONDS + tonumber(ret[2]) * MIN_SECONDS
        slice.begin_time_desc = beginTime
    elseif #ret >= 1 then
        slice.begin_time = tonumber(ret[1]) * HOUR_SECONDS
        slice.begin_time_desc = beginTime .. ":00"
    else
        slice.begin_time = 0
        slice.begin_time_desc = "00:00"
    end

    local period
    if type(endTime) == "number" or tonumber(endTime) then
        period, endTime = tonumber(endTime), nil
    end

    if endTime then
        local ret2 = __split(endTime, ":")
        if #ret2 >= 2 then
            slice.end_time = tonumber(ret2[1]) * HOUR_SECONDS + tonumber(ret2[2]) * MIN_SECONDS
            slice.end_time_desc = endTime
        elseif #ret2 >= 1 then
            slice.end_time = tonumber(ret2[1]) * HOUR_SECONDS
            slice.end_time_desc = endTime .. ":00"
        else
            slice.end_time = "00:00"
        end
    else
        -- period
        if period and period >= 0 then
            slice.end_time = slice.begin_time + period

            local hour = math_floor(slice.end_time / HOUR_SECONDS)
            local minute = math_floor((slice.end_time - hour * HOUR_SECONDS) / MIN_SECONDS)

            slice.end_time_desc = str_format("%02d:%02d", hour, minute)
        else
            -- period < 0 means the end equals the whole cycle end.
            --slice.end_time = 0
            --slice.end_time_desc = "?"
        end
    end

    --
    slice.desc = str_format("%s ~ %s", slice.begin_time_desc, slice.end_time_desc)

    --
    tbl_insert(self.sliceList, slice)
    return slice
end

-- params : fmt:addFormat("23:30", 60) // slice 23:30:00 ~ 23:31:00
--          or fmt:addFormat("23:30", "23:31") // slice 23:30:00 ~ 23:31:00
--          or fmt:addFormat({{p1, p2}})
function _M:addFormat(beginTime, endTime)

    if type(beginTime) == "string" then
        return __addFormat(self, beginTime, endTime)
    elseif type(beginTime) == "table" then
        local t = beginTime
        for i, v in ipairs(t) do
            if type(v) == "table" then
                __addFormat(self, v[1], v[2])
            end
        end
    end
end

--
function _M:adjustSliceEndTime()
    local slice_pre
    for i, v in ipairs(self.sliceList) do
        local slice = v

        if slice_pre and (0 == slice_pre.end_time or slice_pre.end_time > slice_pre.begin_time) then
            slice_pre.end_time = slice.begin_time
        end
        slice_pre = slice
    end
end

-- return slice, cycle, awake, follow
function _M:allocateSlice(tmCheck)
    --
    local slicePointer, cycle, awake, follow = self:findSlicePointerByTime(tmCheck)
    return self:getSliceAt(slicePointer), cycle, awake, follow
end

function _M:getSliceSize()
    return #self.sliceList
end

function _M:getSliceAt(slicePointer)
    if 1 <= slicePointer and slicePointer <= #self.sliceList then
        return self.sliceList[slicePointer]
    end
end

-- return slicePointer, cycle, awake, follow
function _M:findSlicePointerByTime(tmCheck)
    -- 0 means disable
    local slicePointer = 0
    local cycle = {
        base = 0,
        timemin = 0,
        timemax = 0
    }

    --
    self:resetCycle(tmCheck, cycle)

    --
    local awake = false
    local follow = false

    -- walk
    local slice
    local tail
    local count

    count = #self.sliceList
    for i, v in ipairs(self.sliceList) do
        slice = v
        tail = (i == count)

        -- check time slice
        if slice.enable then
            --valid format end time
            local endTime = __getValidFormatEndTime(slice, cycle.timemax)

            -- check wake
            if __isBetweenPeriod(tmCheck, cycle.base, slice.begin_time, endTime) then
                slicePointer = slice.id
                awake = true
                break
            else
                -- check follow
                if __isBetweenPeriod(tmCheck, cycle.base, 0, slice.begin_time) then
                    slicePointer = slice.id
                    follow = true
                    break
                end
            end

            if tail and not awake and not follow then
                -- follow must be next cycle's first item
                self:rollCycleBase(cycle)

                slicePointer = 1
                follow = true
                break
            end
        end
    end
    return slicePointer, cycle, awake , follow
end

--
function _M:nextSlicePointer(slicePointer, cycle)
    if slicePointer >= #self.sliceList then
        self:rollCycleBase(cycle)
        return 1
    end
    return slicePointer + 1
end

--return setmetatable({}, {__call = function(_, ...) return _M.new(...) end})
return _M
