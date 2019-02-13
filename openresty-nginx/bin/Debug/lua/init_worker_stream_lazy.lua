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
ngx.log(ERR, "start upconn.Forward ...")
local mygate_forward = require("serv.mygate.upconn.Forward")
mygate_forward.start()
mygate_forward.check()