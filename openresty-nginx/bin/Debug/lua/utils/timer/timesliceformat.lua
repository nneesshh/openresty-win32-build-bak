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
local str_find = string.find
local str_sub = string.sub
local str_format = string.format 
local tbl_insert = table.insert
local tonumber = tonumber
local tostring = tostring

local cwd = (...):gsub("%.[^%.]+$", "") .. "."

local _M = {
    
}
local mt = {__index = _M}

local MIN_SECONDS = 60
local HOUR_SECONDS = 3600
local DAY_SECONDS = 86400

local function _split(str, sep)
    local ret = {}
    local e = 1
    local b = str_find(str, sep, e)
    while b do
        tbl_insert(ret, str_sub(str, e, b - 1))
        e = b + 1
        b = str_find(str, sep, e)
    end
    tbl_insert(ret, str_sub(str, e, -1))
    return ret
end

local function _getValidFormatEndTime(slice, TIME_MAX)
    return (0 == slice._end_time) and TIME_MAX or slice.end_time
end

local function _isBetweenPeriod(tmCheck, tmBase, beginTime, endTime)
    return tmBase + beginTime <= tmCheck
        and tmCheck < tmBase + endTime
end

function _M.newDaily(name)
    --
    local self = {
        nextId = 1,
        sliceList = {},
    }

    --
    self.rollCycleBase = function(self, cycle)
        local CYCLE_TIME = DAY_SECONDS
        cycle.base = cycle.base + CYCLE_TIME
    end

    --
    self.resetCycle = function(self, tmCheck, cycle)
        -- DatetimeToDate
        local tab = os.date("*t", tmCheck)
        local tmDay = os.time({day=tab.day, month=tab.month, year=tab.year, hour=0, minute=0, second=0})
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
            uEndTime = _getValidFormatEndTime(slice, CYCLE_TIME)
    
            uTimeMin = (slice.begin_time < uTimeMin) and slice.begin_time or uTimeMin
            uTimeMax = (uEndTime > uTimeMax) and uEndTime or uTimeMax
        end
    
        -- adjust bound -- uTimeMax should be greater than CYCLE_TIME at least
        uTimeMin = math_min(uTimeMin, CYCLE_TIME)
        uTimeMax = math_max(uTimeMax, uTimeMin + CYCLE_TIME)

        --
        if _isBetweenPeriod(tmCheck, tmBase, uTimeMin, uTimeMax) then
            cycle.base = tmBase;
            cycle.timemin = uTimeMin;
            cycle.timemax = uTimeMax;
        else
            -- use pre
            tmBase = tmBase - CYCLE_TIME;
            
            cycle.base = tmBase
            cycle.timemin = uTimeMin
            cycle.timemax = uTimeMax
        end
    end

    return setmetatable(self, mt)
end

-- params : fmt:addFormat("23:30", 60) // slice 23:30:00 ~ 23:31:00
--          or fmt:addFormat("23:30", "23:31") // slice 23:30:00 ~ 23:31:00
function _M:addFormat(beginTime, endTime)
    assert(type(beginTime) == 'string')

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
    local ret = _split(beginTime, ':')
    if #ret >= 2 then
        slice.begin_time = tonumber(ret[1]) * HOUR_SECONDS + tonumber(ret[2]) * MIN_SECONDS
        slice.begin_time_desc = beginTime

        local period

        if type(endTime) == 'number' or tonumber(endTime)  then
            period, endTime = tonumber(endTime), nil
        end

        if endTime then
            local ret2 = _split(endTime, ':')
            if #ret2 >= 2 then
                slice.end_time = tonumber(ret2[1]) * HOUR_SECONDS + tonumber(ret2[2]) * MIN_SECONDS
                slice.end_time_desc = endTime
            end
        else
            -- period < 0 means the end equals the whole cycle end.
            if period >= 0 then
                slice.end_time = slice.begin_time + period

                local hour = slice.end_time / HOUR_SECONDS
                local minute = (slice.end_time - hour * HOUR_SECONDS) / MIN_SECONDS

                str_format(slice.end_time_desc, "%02d:%02d", hour, minute)
            end
        end

        --
        str_format(slice.desc, "%s-%s", slice.begin_time_desc, slice.end_time_desc)
    end

    --
    tbl_insert(self.sliceList, slice)
	return slice
end

--
function _M:adjustSliceEndTime()
    local slice_pre
    for i, v in ipairs(self.sliceList) do
        local slice = v

		if slice_pre and (0 == slice_pre.end_time or slice_pre._end_time > slice_pre.begin_time) then
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
    if 1 <= slicePointer and slicePointer <= #self:sliceList then
        return self:sliceList[slicePointer]
    end
    return nil
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

	count = #self:sliceList
	for i, v in ipairs(self:sliceList) do
		slice = v
		tail = (i == count)

		-- check time slice
		if slice.enable then
			--valid format end time
			local endTime = _getValidFormatEndTime(slice, cycle._timemax)

			-- check wake
			if _isBetweenPeriod(tmCheck, cycle._base, slice.begin_time, endTime) then
				slicePointer = slice.id
				awake = true
				break
			else
				-- check follow
				if _isBetweenPeriod(tmCheck, cycle._base, 0, slice.begin_time) then
					slicePointer = slice.id
					follow = true
					break
                end
            end

			if tail
				and not awake
				and not follow then
				-- follow must be next cycle's first item
				self:rollCycleBase(cycle)

				slicePointer = 1
				follow = true
				break
			end
		end
	end
	return slicePointer
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
