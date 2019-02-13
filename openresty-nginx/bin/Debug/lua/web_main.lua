local b = require "bootstrap"
--[[]]
--require("mobdebug_start")
--[[]]
-- require("test_web")

-- ]]
local lapis = require("lapis")
local lapis_serve = lapis.serve
lapis_serve("web.lapis_app")
--[[]]
