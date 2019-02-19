-- common
package.path = package.path .. ";./?.lua;./lua/?.lua;./lua/?/init.lua"
package.path = package.path .. ";./lualibs/?.lua;./lualibs/?/init.lua"
package.path = package.path .. ";./src/?.lua;./src/?/init.lua"
package.cpath = package.cpath .. ";./?.dll;./clibs/?.dll"

-- date
package.path = package.path .. ";./lualibs/luadate-2.1/?.lua"

local timermanager = require("utils.timer.timermanager")
local formatCls = require("utils.timer.timesliceformat")

local formatDaily = formatCls:newDaily()
local formatWeekly = formatCls:newWeekly()
local formatMonthly = formatCls:newMonthly()

--[[]]
formatDaily:addFormat(
    {
        {"11:35", 1},
        {"11:36", 1},
        {"11:37", 1},
        {"11:39", "11:40"},
        {"11:41", "11:42"},
        {"11:43", "11:44"},
        {"11:45", "11:46"},
        {"11:47", "11:48"},
        {"11:48", "11:49"},
        {"11:49", "11:50"},
        {"11:51", "11:55"},
        {"11:56", "11:59"},
        {"12:00", 60},
        {"12:01", 60},
        {"12:02", 60},
        {"12:03", 60},
        {"12:04", 60},
        {"12:05", 60},
        {"12:30", "12:59"},
        {"12:59", 60},
        {"13:00", "13:10"},
        {"13:11", "13:20"},
        {"13:21", "13:30"}
    }
)
--[[]]

formatMonthly:addFormat(
    {
        -- day1 00:00:00 ~ day14 14:20:00
        {"00:00", 86400 * 13 + 3600 * 14 + 60 * 20},
    }
)

--local testSlicer = timermanager.createTimeSlicer("test", formatDaily)
local testSlicer = timermanager.createTimeSlicer("test", formatMonthly)

local onBegin = function(ticker, slice)
    print("onBegin:", slice.id, slice.desc, os.date(), os.date("%Y-%m-%d %H:%M:%S"))
end

local onEnd = function(ticker, slice)
    print("onEnd:", slice.id, slice.desc, os.date(), os.date("%Y-%m-%d %H:%M:%S"))
end

testSlicer:startTick(onBegin, onEnd)

while true do
    timermanager.advance()
end
