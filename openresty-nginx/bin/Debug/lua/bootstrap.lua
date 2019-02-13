require = require("utils.require").require
local cls = require "utils.classutil"
require "utils.extension"

local math = math
math.pow = math.pow or function(x, y)
        return x ^ y
    end

local match = string.match
local floor = math.floor

local randseed = math.randomseed
local rand = math.random
local rand_init = function()
    math.randomseed(os.time())
    math.random(1, 10000)
end
rand_init()

local inspect = require "utils.inspect"
local serpent = require "utils.serpent"

-- any to string
local ats = inspect
local ats2 = serpent.block

local print_any_by_inspect = function(...)
    print(ats(...))
end
local print_any_by_serpent = function(...)
    print(ats2(...))
end

return {
    pa = print_any_by_inspect,
    pa2 = print_any_by_serpent
}
