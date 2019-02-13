-- Localize
local tbl_insert = table.insert
local ipairs = ipairs
local cwd = (...):gsub("%.[^%.]+$", "") .. "."
local session_manager = require(cwd .. "session_manager")
local serverd = require(cwd .. "server")

local _M = {
    ssmgr_list = {},
    --
    next_ssmgr_id = 1
}

--
function _M.create(name)
    local next_ssmgr_id = _M.next_ssmgr_id
    _M.next_ssmgr_id = _M.next_ssmgr_id + 1

    local ssmgr = session_manager:new(next_ssmgr_id, name)
    tbl_insert(_M.ssmgr_list, ssmgr)
    return ssmgr
end

--
function _M.get(name)
    for i, v in ipairs(_M.ssmgr_list) do
        if v.name == name then
            return v
        end
    end
end

--
function _M.get_at(i)
    return _M.ssmgr_list[i]
end

--
function _M.get_first()
    return _M.get_at(1)
end

return _M
