--[[
  {
        id = 1001, 
        type = 1, -- 'upstream type : 1 = game, 2 = chat',
        name = '游戏服务器1', -- '名称',
        host = '127.0.0.1',
        port = 8861,
        visibility = 1, -- '可见性，1=正式服，2=测试服，3=审核服',
        white_peerip = '', -- '白名单peer ip，服务器强制可见 -- "ip : mask | ..."',
        enable = 1 -- '是否启用，0 = 禁用， 1 = 启用',
  },
]]
local _M = {
    {
        id = 1000,
        type = 1,
        name = "Gate服务器1",
        host = "192.168.1.213",
        port = 8860,
        visibility = 1,
        white_peerip = "",
        enable = true
    },
    {
        id = 1001,
        type = 1,
        name = "游戏服务器1",
        host = "127.0.0.1",
        port = 8861,
        visibility = 1,
        white_peerip = "",
        enable = false
    },
    {
        id = 1002,
        type = 2,
        name = "聊天服务器1",
        host = "127.0.0.1",
        port = 8862,
        visibility = 1,
        white_peerip = "",
        enable = false
    }
}

return _M
