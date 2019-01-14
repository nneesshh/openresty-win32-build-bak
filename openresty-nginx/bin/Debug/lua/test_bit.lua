local bit = require("bit")

local function bin2hex(s)
    s =
        string.gsub(
        s,
        "(.)",
        function(x)
            return string.format("%02X ", string.byte(x))
        end
    )
    return s
end

local h2b = {
    ["0"] = 0,
    ["1"] = 1,
    ["2"] = 2,
    ["3"] = 3,
    ["4"] = 4,
    ["5"] = 5,
    ["6"] = 6,
    ["7"] = 7,
    ["8"] = 8,
    ["9"] = 9,
    ["A"] = 10,
    ["B"] = 11,
    ["C"] = 12,
    ["D"] = 13,
    ["E"] = 14,
    ["F"] = 15
}

local function hex2bin(hexstr)
    local s =
        string.gsub(
        hexstr,
        "(.)(.)%s",
        function(h, l)
            return string.char(h2b[h] * 16 + h2b[l])
        end
    )
    return s
end

function printx(x)
    print("0x" .. bit.tohex(x))
end

function printbin(x)
    print("bin..." .. hex2bin(bit.tohex(x)))
end

print(bit.lshift(1, 0)) -- > 1
print(bit.lshift(1, 8)) -- > 256
print(bit.lshift(1, 40)) -- > 256
print(bit.rshift(256, 8)) -- > 1
print(bit.rshift(-256, 8)) -- > 16777215
print(bit.arshift(256, 8)) -- > 1
print(bit.arshift(-256, 8)) -- > -1
printx(bit.lshift(0x87654321, 12)) -- > 0x54321000
printx(bit.rshift(0x87654321, 12)) -- > 0x00087654
printx(bit.arshift(0x87654321, 12)) -- > 0xfff87654

print("\n22222222222222222222")
local fl = bit.tobit(string.byte("z") * 256 + string.byte("z"))
print(fl)
printx(fl)

local fl2 = bit.rshift(fl, 2)
print(fl2)
printx(fl2)

print("\n33333333333333333333333")
local b3 = bit.band(fl, 0x3FFF)
print(b3)
printx(b3)
printbin(b3)
