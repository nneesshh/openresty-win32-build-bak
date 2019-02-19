package.path = package.path .. ";./?.lua;./lua/?.lua;./lua/?/init.lua;"
package.cpath = package.cpath .. ";./?.dll;./clibs/?.dll"

--require("mobdebug_start")
local verbose = false
if verbose then
    local dump = require "jit.dump"
    dump.on(nil, "temp/jit.log")
else
    local v = require "jit.v"
    v.on("temp/jit.log")
end

local lpb = require "lpb"
local pa = require "utils.serpent".block

-- test lpb
assert(lpb.loadfile("proto_pb/output/gate/lua/Gate.pb"))

local reg = {
    req = {
        uid = "Alice",
        pwd = "a12345",
        nick = "nick0001",
        email = "email0001",
        sponsor_uid = "sponsor_uid0001"
    },
    resp = {
        result = -9001
    }
}

local login = {
    req = {
        uid = "Alice",
        pwd = "a12345",
        ws_entryid = 123456,
        channel_platid = "channel_platidchannel_platidchannel_platidchannel_platidchannel_platidchannel_platid0001",
        channel_gameid = "channel_gameidchannel_gameidchannel_gameidchannel_gameid0001"
    },
    resp = {
        result = -9002,
        uuid = 1234567890123456
    }
}

local server_list = { list = {}}
for i = 1, 100 do
    table.insert(
        server_list.list,
        {
            id = i,
            name = "testserver" .. i
        }
    )
end

local start = os.clock()
for i = 1, 10000 do
    --
    local reg_data = assert(lpb.encode("gate.RegisterAccountService", reg))
    local reg_msg = assert(lpb.decode("gate.RegisterAccountService", reg_data))
    --
    local login_data = assert(lpb.encode("gate.AccountLoginService", login))
    local login_msg = assert(lpb.decode("gate.AccountLoginService", login_data))
    --
    local server_list_data = assert(lpb.encode("gate.GameServerList", server_list))
    local server_list_msg = assert(lpb.decode("gate.GameServerList", server_list_data))

    --[[
    print(pa(reg_msg))
    print("+++++++++++++++++++++++++++++++++")

    print(pa(login_msg))
    print("=================================")

    print(pa(server_list_msg))
    print("#################################")

    --[[]]
end

local over = os.clock()
local elapsed = over - start

print("test_lpb -- elapsed: " .. tostring(elapsed))
