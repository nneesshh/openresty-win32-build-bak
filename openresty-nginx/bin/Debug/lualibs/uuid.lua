local _M = {}

--[[ pure lua ]]
local luauuid = require("luauuid.src.uuid")
luauuid.seed()
_M.generate = function()
  return luauuid()
end
--[[]]

--[[ resty jit-uuid
local jituuid = require("resty.jit-uuid")
jituuid.seed()
_M.generate = function()
  return jituuid.generate_v4()
end
--]]

return _M


