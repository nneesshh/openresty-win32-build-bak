--[[ ]]
local ok, res, err, errcode, sqlstate
local db
local mysql = require("resty.mysql")
    
db, err = assert(mysql:new())
db:set_timeout(1110000)

ok, err, errcode, sqlstate = db:connect{
    host = "127.0.0.1",
    port = 3306,
    database = "my_umb_web",
    user = "root",
    password = "123123",
    charset = "utf8",
    max_packet_size = 1024 * 1024 * 10,
}

if not ok then
    ngx.say("failed to connect: ", err, ": ", errcode, " ", sqlstate)
    ngx.exit(403)
    return
end

ngx.say("connected to mysql.")

res, err, errcode, sqlstate = db:query("select * from Users")
if not res then
    ngx.say("bad result: ", err, ": ", errcode, ": ", sqlstate, ".")
    ngx.exit(403)
end
ngx.say("xxxxxxxxxxxxxxxxxxxx")
ngx.exit(200)
--[[]]