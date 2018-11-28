-- stringutil
local _M = {}

local constCharByte = {
    WhiteSpace       = string.byte(' '),
    DoubleQuote      = string.byte('\"'),

    LeftParentheses  = string.byte('('),
    LeftParentheses  = string.byte(')'),
    LeftBracket      = string.byte('['),
    RightBracket     = string.byte(']'),
    LeftBraces       = string.byte('{'),
    RightBraces      = string.byte('}'),

    Comma            = string.byte(","),
    Colon            = string.byte(":"),
    Semicolon        = string.byte(";"),

    Slash            = string.byte("/"),
    Backslash        = string.byte("\\"),
}

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
        return string.lower(str1) == string.lower(str2)
    else
        return str1 == str2
    end
end

function _M.trimEnclosedDoubleQuotes(str)
    if string.byte(str, 1, 1) == constCharByte.DoubleQuote and string.byte(str, -1, -1) == constCharByte.DoubleQuote then
        return string.sub(str, 2, -2), true
    else
        return str, false
    end
end

function _M.trimEnclosedBrackets(str)
    if string.byte(str, 1, 1) == constCharByte.LeftBraces and string.byte(str, -1, -1) == constCharByte.RightBraces then
        return string.sub(str, 2, -2), true
    else
        return str, false
    end
end

function _M.skipPairedBrackets(str, startPos)
    if string.byte(str, startPos) == constCharByte.LeftBraces then
        local depth = 0
        local posIt = startPos
        local strLen = string.len(str)

        while posIt <= strLen do
            if string.byte(str, posIt) == constCharByte.LeftBraces then
                depth = depth + 1
            
            elseif string.byte(str, posIt) == constCharByte.RightBraces then
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

function _M.split(str, char)
    local ret = {}
    local e = 1
    local b = string.find(str, char, e)
    while b do
        table.insert(ret, string.sub(str, e, b - 1))
        e = b + 1
        b = string.find(str, char, e)
    end
    table.insert(ret, string.sub(str, e, -1))
    return ret
end

function _M.splitTokens(str)
    local ret = {}
    
    if string.byte(str, 1, 1) == constCharByte.DoubleQuote then
        table.insert(ret, str)
        return ret
    end

    -- //"int Self.AgentArrayAccessTest::ListInts[int Self.AgentArrayAccessTest::l_index]"
    local pB = 1
    local i = 1
    local bBeginIndex = false
	local strLen = string.len(str)

    while i < strLen do
        local bFound = false
        local c = string.byte(str, i)

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
            local strT = string.sub(str, pB, i - 1)
            table.insert(ret, strT)

            pB = i + 1
        end

        i = i + 1
    end

    -- last one
    local strT = string.sub(str, pB, i)
    if string.len(strT) > 0 then
        table.insert(ret, strT)
    end

    return ret
end

return _M