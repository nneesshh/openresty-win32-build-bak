require "utils.functions"

local math = math
math.pow = math.pow or function(x, y)
        return x ^ y
    end

local match = string.match
local floor = math.floor

local inspect = require "utils.inspect"
local serpent = require "utils.serpent"

-- any to string
ats = inspect
ats2 = serpent.block

local print_any_by_inspect = function(...)
    print(ats(...))
end
local print_any_by_serpent = function(...)
    print(ats2(...))
end

pa = print_any_by_inspect
pa2 = print_any_by_serpent
