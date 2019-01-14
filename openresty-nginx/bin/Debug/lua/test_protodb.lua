local Model = require("lapis.db.model").Model
local lapis_redis = require("lapis.redis")

local pb = require("StoredProcConfig_pb")

local db_opts = {
    database = "sandbox",
    user = "root",
    password = "123123",
    ssl = nil,
    ssl_verify = nil,
    charset = "utf8",
    host = "127.0.0.1",
    port = 3306
}

local r_opts = {
    host = "127.0.0.1",
    port = 6379
}

local function _createMessage(row, msgname)
    local msg = pb[msgname]()
    for k, v in pairs(row) do
        msg[k] = v
    end
    return msg
end

local function _getSubId(msg, subidKey)
    local ret
    if not subidKey then
        ret = "1"
    else
        ret = tostring(msg[subidKey])
    end
    return ret
end

local function _createIdHash(moduleName, mainId, msg, subkey)
    local subid = _getSubId(msg, subkey)
    return moduleName .. ":" .. mainId .. ":" .. subid .. ":H"
end

local db_entity =
    Model:extend(
    db_opts,
    "config_achievement",
    {
        primary_key = "id"
    }
)

local result =
    db_entity:select(
    "WHERE 1=1",
    {
        fields = "*"
    }
)
if result then
    local row = result[1]
    local msg = _createMessage(row, "ConfigAchievement")
    local meta = getmetatable(msg)
    local mainId = string.sub(meta._descriptor.full_name, 2)
    local rkey = _createIdHash("{sandbox}", mainId, msg, subkey)

    dump("rkey=" .. rkey)
    local redis = lapis_redis.get_redis(r_opts)
    local bytes = msg:SerializeToString()
    redis:set(rkey, bytes)
end

print("====================================")
--[[]]
