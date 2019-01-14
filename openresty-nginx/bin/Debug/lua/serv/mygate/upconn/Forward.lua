local tostring = tostring

local _M = {
    upconnMap = {},

    --
    nextTokenId = 1,
    running = false
}

-- Localize
local cwd = (...):gsub("%.[^%.]+$", "") .. "."
local pdir = (...):gsub("%.[^%.]+%.[^%.]+$", "") .. "."
local cfg_upconn = require(pdir .. "config.cfg_upconn")
local uptcpd = require("serv.network.uptcp")

--
function _M.onUpconnAdd(upconn)
    local nextTokenId = _M.nextTokenId
    _M.nextTokenId = _M.nextTokenId + 1

    local token = {
        id = nextTokenId,
        upconn = upconn,
        released = false
    }
    _M.upconnMap[upconn] = token
    return token
end

--
function _M.onUpconnRemove(sock)
    local token = _M.upconnMap[sock]
    if token then
        token.release = true
        _M.upconnMap[sock] = nil
    end
end

--
function _M.onForward(msg, msgSn)
    print("forward:", req.cmd)

    
end

--
function _M.sendRequest(robot, args) -- (unit, cmd, itemid, areaid, coord_x, coord_y)
    print("sendUserTreasureMapService", args.cmd)
    local msg = UserTreasureMap_pb.UserTreasureMapService()
    msg.req.cmd = args.cmd
    msg.req.itemid = args.itemid or 0
    msg.req.areaid = args.areaid or 0
    msg.req.coord_x = args.coord_x or 0
    msg.req.coord_y = args.coord_y or 0

    robot_manager.sendMessage(robot, "sg.UserTreasureMapService", msg)
end

--
function _M.createUpconn(opts)
    --
    local upconn = uptcpd.new(opts) 
    _M.onUpconnAdd(upconn)
    return upconn
end

--
function _M.destroyUpconn(s)

end

--
function _M.check()
    for k, v in pairs(_M.upconnMap) do
        print("Forward: ", tostring(k), tostring(v))

    end
end

--
function _M.start()
    if not _M.running then
      
      local connected_cb = function(self)
        
      end
      
      local disconnected_cb = function(self)
        
      end
      
      local got_packet_cb = function(self)
        
      end
      
      --
      for i, v in ipairs(cfg_upconn) do
          local upconn = _M.createUpconn()
          local opts = {
            cfg = v,
            connected_cb = connected_cb,
            disconnected_cb = disconnected_cb,
            got_packet_cb = got_packet_cb,
          }
          
          --
          upconn:run(opts)
          break
      end
      
      --
      _M.running = true
    end
end

return setmetatable(
    _M,
    {
        __call = function(_, msg, msgSn)
            _M.onForward( msg, msgSn)
        end
    }
)
