local _M = {
  _VERSION = "1.0.0.1",
  _DESCRIPTION = "server for persistent connection ..."
}

-- Localize
local cwd = (...):gsub("%.[^%.]+$", "") .. "."
local packet1 = require(cwd .. "outer_packet")
local packet2 = require(cwd .. "inner_packet")

--
_M.serve = function(connected_cb, disconnected_cb, got_packet_cb, packet_type)
  local workerid = ngx.worker.id()
  local req = ngx.req
  local s = req.socket()
  local pkt

  ngx.ctx.curr_conn = {}

  --
  local mygate_forward = require("serv.mygate.upconn.Forward")
  ngx.log(ngx.ERR, "forward debug")
  mygate_forward.start()
  mygate_forward.check()

  --
  if not s then
    return nil, "no socket: workerid: " .. workerid
  end
  ngx.ctx.curr_conn.downstream = s

  --
  packet_type = packet_type or 1
  if packet_type == 1 then
    packet_obj = packet1.new()
  else
    packet_obj = packet2.new()
  end
  ngx.ctx.curr_conn.packet_obj = packet_obj

  --1s, 1s, 25 minutes
  s:settimeouts(1000, 1000, 1000 * 60 * 25) -- timeout for connect/send/receive
  connected_cb(s)

  --[[ --IOCP DOES NOT SUPPORT check_client_abort
  local function my_cleanup()
    --ngx.exit(499)
    _M.disconnected_cb(s)
  end

  local ok, regerr = ngx.on_abort(my_cleanup)
  if not ok then
     ngx.log(ngx.ERR, "failed to register the on_abort callback: ", regerr)
     ngx.exit(500)
  end
 --]]
  while true do
    -- read packet
    local pkt, err = packet_obj:read(s)
    if not pkt then
      ngx.say("failed to read packet: ", err)
      break
    end

    if got_packet_cb then
      -- packet dispatcher
      got_packet_cb(pkt)
    end
  end

  disconnected_cb(s)
  return 1
end

return _M
