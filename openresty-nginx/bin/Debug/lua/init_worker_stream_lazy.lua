local delay = 60 -- in seconds
local STDERR = ngx.STDERR
local EMERG = ngx.EMERG
local ALERT = ngx.ALERT
local CRIT = ngx.CRIT
local ERR = ngx.ERR
local WARN = ngx.WARN
local NOTICE = ngx.NOTICE
local INFO = ngx.INFO
local DEBUG = ngx.DEBUG

--
require = require("utils.require").require
require("bootstrap_app")
--[[
ngx.log(NOTICE, "start Forward ...")
local d = require("serv.mygate.upconn.Forward")
]]

ngx.log(NOTICE, "start ZjhTest...")
local d = require("serv.mygate.upconn.ZjhTest")

d.start()
d.check()