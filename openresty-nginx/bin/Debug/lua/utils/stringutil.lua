local str_len = string.len
local str_byte = string.byte
local str_upper = string.upper
local str_lower = string.lower
local str_format = string.format
local str_rep = string.rep
local str_gsub = string.gsub
local str_sub = string.sub
local str_find = string.find
local tbl_insert = table.insert

-- stringutil
local _M = {}

local constCharByte = {
    WhiteSpace = str_byte(" "),
    DoubleQuote = str_byte('"'),
    LeftParentheses = str_byte("("),
    LeftParentheses = str_byte(")"),
    LeftBracket = str_byte("["),
    RightBracket = str_byte("]"),
    LeftBraces = str_byte("{"),
    RightBraces = str_byte("}"),
    Comma = str_byte(","),
    Colon = str_byte(":"),
    Semicolon = str_byte(";"),
    Slash = str_byte("/"),
    Backslash = str_byte("\\")
}

--------------------------------------------------------------------------------
--
--------------------------------------------------------------------------------

local function strltrim_(input)
    return str_gsub(input, "^[ \t\n\r]+", "")
end

local function strrtrim_(input)
    return str_gsub(input, "[ \t\n\r]+$", "")
end

local function strtrim_(input)
    input = str_gsub(input, "^[ \t\n\r]+", "")
    return str_gsub(input, "[ \t\n\r]+$", "")
end

local function strsplit_(input, delimiter)
    input = tostring(input)
    delimiter = tostring(delimiter)
    if (delimiter == "") then
        return false
    end
    local pos, arr = 0, {}
    -- for each divider found
    for st, sp in function()
        return str_find(input, delimiter, pos, true)
    end do
        table.insert(arr, str_sub(input, pos, st - 1))
        pos = sp + 1
    end
    table.insert(arr, str_sub(input, pos))
    return arr
end

function _M.dump(value, desciption, nesting)
    if type(nesting) ~= "number" then
        nesting = 3
    end

    local lookupTable = {}
    local result = {}

    local traceback = strsplit_(dbg_traceback("", 2), "\n")
    print("dump from: " .. strtrim_(traceback[3]))

    local function dump_(value, desciption, indent, nest, keylen)
        desciption = desciption or "<var>"
        local spc = ""
        if type(keylen) == "number" then
            spc = str_rep(" ", keylen - str_len(dump_value_(desciption)))
        end
        if type(value) ~= "table" then
            result[#result + 1] = str_format("%s%s%s = %s", indent, dump_value_(desciption), spc, dump_value_(value))
        elseif lookupTable[tostring(value)] then
            result[#result + 1] = str_format("%s%s%s = *REF*", indent, dump_value_(desciption), spc)
        else
            lookupTable[tostring(value)] = true
            if nest > nesting then
                result[#result + 1] = str_format("%s%s = *MAX NESTING*", indent, dump_value_(desciption))
            else
                result[#result + 1] = str_format("%s%s = {", indent, dump_value_(desciption))
                local indent2 = indent .. "    "
                local keys = {}
                local keylen = 0
                local values = {}
                for k, v in pairs(value) do
                    keys[#keys + 1] = k
                    local vk = dump_value_(k)
                    local vkl = str_len(vk)
                    if vkl > keylen then
                        keylen = vkl
                    end
                    values[k] = v
                end
                tbl_sort(
                    keys,
                    function(a, b)
                        if type(a) == "number" and type(b) == "number" then
                            return a < b
                        else
                            return tostring(a) < tostring(b)
                        end
                    end
                )
                for i, k in ipairs(keys) do
                    dump_(values[k], k, indent2, nest + 1, keylen)
                end
                result[#result + 1] = str_format("%s}", indent)
            end
        end
    end
    dump_(value, desciption, "- ", 1)

    for i, line in ipairs(result) do
        print(line)
    end
end

--------------------------------------------------------------------------------
--
--------------------------------------------------------------------------------
function _M.isNullOrEmpty(str)
    return not str or str == ""
end

function _M.isValidString(str)
    return str and str ~= ""
end

function _M.compare(str1, str2, bIgnoreCase)
    bIgnoreCase = bIgnoreCase or false
    if bIgnoreCase then
        return str_lower(str1) == str_lower(str2)
    else
        return str1 == str2
    end
end

function _M.trimEnclosedDoubleQuotes(str)
    if str_byte(str, 1, 1) == constCharByte.DoubleQuote and str_byte(str, -1, -1) == constCharByte.DoubleQuote then
        return str_sub(str, 2, -2), true
    else
        return str, false
    end
end

function _M.trimEnclosedBrackets(str)
    if str_byte(str, 1, 1) == constCharByte.LeftBraces and str_byte(str, -1, -1) == constCharByte.RightBraces then
        return str_sub(str, 2, -2), true
    else
        return str, false
    end
end

function _M.skipPairedBrackets(str, startPos)
    if str_byte(str, startPos) == constCharByte.LeftBraces then
        local depth = 0
        local posIt = startPos
        local strLen = str_len(str)

        while posIt <= strLen do
            if str_byte(str, posIt) == constCharByte.LeftBraces then
                depth = depth + 1
            elseif str_byte(str, posIt) == constCharByte.RightBraces then
                depth = depth - 1
                if depth == 0 then
                    return posIt
                end
            end

            posIt = posIt + 1
        end
    end

    return 0
end

function _M.split(str, sep)
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

function _M.splitTokens(str)
    local ret = {}

    if str_byte(str, 1, 1) == constCharByte.DoubleQuote then
        tbl_insert(ret, str)
        return ret
    end

    -- //"int Self.AgentArrayAccessTest::ListInts[int Self.AgentArrayAccessTest::l_index]"
    local pB = 1
    local i = 1
    local bBeginIndex = false
    local strLen = str_len(str)

    while i < strLen do
        local bFound = false
        local c = str_byte(str, i)

        if c == constCharByte.WhiteSpace and not bBeginIndex then
            bFound = true
        elseif c == constCharByte.LeftBracket then
            bBeginIndex = true
            bFound = true
        elseif c == constCharByte.RightBracket then
            bBeginIndex = false
            bFound = true
        end

        if bFound then
            local strT = str_sub(str, pB, i - 1)
            tbl_insert(ret, strT)

            pB = i + 1
        end

        i = i + 1
    end

    -- last one
    local strT = str_sub(str, pB, i)
    if str_len(strT) > 0 then
        tbl_insert(ret, strT)
    end

    return ret
end

return _M
