local lapis = require("lapis")
local db = require("lapis.db")
local Model = require("lapis.db.model").Model
local schema = require("lapis.db.schema")
local types = schema.types

local uuid = require("uuid")

-- Localize
local cwd = (...):gsub("%.[^%.]+$", "") .. "."
local gate_options = require(cwd .. "gate_options").getOptions()

local _M = {
    _db_entity = Model:extend(
        gate_options,
        "gate_account",
        {
            primary_key = "userid"
        }
    )
}

function _M.checkUserId(userId)
    local result =
        _M._db_entity:select(
        "WHERE userid = ?",
        userId,
        {
            fields = "*"
        }
    )
    return result and #result > 0
end

function _M.get(userid)
    return _M._db_entity:find(userid)
end

function _M.getAll(userid)
    return _M._db_entity:select(
        "WHERE 1=1 ORDER BY userid DESC",
        {
            fields = "*"
        }
    )
end

function _M.registerAccount()
    local data = {}
    local res, d1, d2 = db.query(oss_options, "CALL __oss_do_stats_online_snapshot(?)", theQueryTime)
    if res then
        local n = #res
        if n >= 2 then
            for i, row in ipairs(res[1]) do
                table.insert(data, row)
            end
        end
    end
    return data
end

return _M
