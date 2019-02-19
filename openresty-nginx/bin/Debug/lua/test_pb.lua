package.path = package.path .. ";./?.lua;./lua/?.lua;./lua/?/init.lua;"
package.cpath = package.cpath .. ";./?.dll;./clibs/?.dll"

-- protobuf
package.path = package.path .. ";./lualibs/protobuf/?.lua"

--require("mobdebug_start")
local verbose = false
if verbose then
    local dump = require "jit.dump"
    dump.on(nil, "temp/jit.log")
else
    local v = require "jit.v"
    v.on("temp/jit.log")
end

local pb = require "pb"
local pa = require "utils.serpent".block

-- tes pb
local Gate_pb = require("proto_pb.output.gate.lua.Gate_pb")
local reg_msg = Gate_pb.RegisterAccountService()
reg_msg.req.uid = "Alice"
reg_msg.req.pwd = "a12345"
reg_msg.req.nick = "nick0001"
reg_msg.req.email = "email0001"
reg_msg.req.sponsor_uid = "sponsor_uid0001"
reg_msg.resp.result = -9001

local login_msg = Gate_pb.AccountLoginService()
login_msg.req.uid = "Alice"
login_msg.req.pwd = "a12345"
login_msg.req.ws_entryid = 123456
login_msg.req.channel_platid = "channel_platidchannel_platidchannel_platidchannel_platidchannel_platidchannel_platid0001"
login_msg.req.channel_gameid = "channel_gameidchannel_gameidchannel_gameidchannel_gameid0001"
login_msg.resp.result = -9002
login_msg.resp.uuid = 12345678901

local server_list_msg = Gate_pb.GameServerList()
for i = 1, 100 do
    local server_msg = server_list_msg.list:add()
    server_msg.id = i
    server_msg.name = "testserver" .. i
end

local start = os.clock()
for i = 1, 1000 do
    -- 

    local reg_data = reg_msg:SerializeToString()
    local reg_msg2 = Gate_pb.RegisterAccountService()
    --local reg_msg2 = reg_msg
    reg_msg2:ParseFromString(reg_data)
    -- 
    local login_data = login_msg:SerializeToString()
    local login_msg2 = Gate_pb.AccountLoginService()
    --local login_msg2 = login_msg
    login_msg2:ParseFromString(login_data)
    -- 
    local server_list_data = server_list_msg:SerializeToString()
    local server_list_msg2 = Gate_pb.GameServerList()
    --local server_list_msg2 = server_list_msg
    server_list_msg2:ParseFromString(server_list_data)

    --[[
    print(pa(reg_msg2))
    print("+++++++++++++++++++++++++++++++++")

    print(pa(login_msg2))
    print("=================================")

    print(pa(server_list_msg))
    print("#################################")

    --[[]]
end

local over = os.clock()
local elapsed = over - start

print("test_pb elapsed: " .. tostring(elapsed))

