local lapis = require("lapis")
local appconfig = require("lapis_appconfig")
local config = appconfig.getConfig()

local db_options = require("db.mysql_options")

local function copy(obj, seen)
  if type(obj) ~= "table" then
    return obj
  end
  if seen and seen[obj] then
    return seen[obj]
  end
  local s = seen or {}
  local res = setmetatable({}, getmetatable(obj))
  s[obj] = res
  for k, v in pairs(obj) do
    res[copy(k, s)] = copy(v, s)
  end
  return res
end

if config.postgres then
  local options = {}
  for k, v in pairs(config.postgres) do
    options[k] = v
  end
  return options
elseif config.mysql then
  return db_options.new(config.mysql)
else
  return error("You have to configure either postgres or mysql")
end
