-- common
package.path = package.path .. ";./?.lua;./lua/?.lua;./lua/?/init.lua"
package.path = package.path .. ";./lualibs/?.lua;./lualibs/?/init.lua"
package.path = package.path .. ";./src/?.lua;./src/?/init.lua"
package.cpath = package.cpath .. ";./?.dll;./clibs/?.dll"

-- date
package.path = package.path .. ";./lualibs/luadate-2.1/?.lua"

local timermanager = require("utils.timer.timermanager")
local ticker = timermanager.createTimeTicker("test")

local player = {x = 100, y = 100}
ticker:tween(100, player, {x = 200, y = 200}, 'linear', function() print('Player tween linear finished!') end)
--ticker:tween(100, player, {x = 200, y = 200}, 'in-out-cubic', function() print('Player tween in-out-cubic finished!') end)

for i = 1, 100 do
    local x, y = player.x, player.y
    timermanager.update(5)

    print(i, x, y)
    print("x: " .. tostring(player.x) .. " -- " .. tostring(player.x - x))
    print("y: " .. tostring(player.y) .. " -- " .. tostring(player.y - y))
end