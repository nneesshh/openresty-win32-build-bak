local tcp = ngx.socket.tcp
local semaphore = require "ngx.semaphore"
local setmetatable = setmetatable
local tostring = tostring

local ok, new_tab = pcall(require, "table.new")
if not ok then
  new_tab = function(narr, nrec)
    return {}
  end
end

local _M = {
  _VERSION = "0.21",
  _DESCRIPTION = "wrapper of tcp upstream"
}

-- constant
local CONNECT_TIMEOUT = 1000 -- ms
local STATE_CONNECTED = 1

--
local mt = {__index = _M}

function _M.new(self)

  return setmetatable({
      --
      sock = false,
      --
      sema_send = false,
      sema_send_buffer = false,      
      --
      enable_reconnect = true,
      reconnect_delay_seconds = 100.001,
  }, mt)
end

function _M.set_timeout(self, timeout)
  local sock = self.sock
  if not sock then
    return nil, "not initialized"
  end

  return sock:settimeout(timeout)
end

function _M.connect(self, opts)
  local sock = self.sock
  if not sock then
    return nil, "not initialized"
  end
  
  --1s, 1s, 9999 minutes(read never timeout)
  sock:settimeouts(1000, 1000, 1000 * 60 * 9999) -- timeout for connect/send/receive

  local ok, err

  local host = opts.cfg.host
  if host then
    local port = opts.cfg.port or 8860

    ok, err = sock:connect(host, port)
  else
    local path = opts.cfg.path
    if not path then
      return nil, 'neither "host" nor "path" options are specified'
    end

    ok, err = sock:connect("unix:" .. path)
  end

  if not ok then
    return nil, "failed to connect: " .. err
  end

  -- sema
  self.state = STATE_CONNECTED
  self.sema_send = semaphore.new()
  self.sema_send_buffer = {}
  
  local function sema_send_handler()
      while true do
        local ok, err = self.send_sema:wait(60)  -- wait for 1 min at most
        if not ok then
            if err ~= 'timeout' then
              return nil, "sema_send_handler: failed to wait on sema: " .. err
            end
        else
            self.sock:send(table.concat(self.sema_send_buffer))
        end
      end
  end
  
  local co = ngx.thread.spawn(sema_send_handler)

  -- cb
  opts.connected_cb(self)
  return 1
end

function _M.close(self)
  local sock = self.sock
  if not sock then
    return nil, "not initialized"
  end

  self.state = nil

  return sock:close()
end

function _M.post_to_sema(self, data)
    table.instert(self.sema_send_buffer, data)
    self.sema_send.post(1)
end

--
function _M.run(self, opts)
    
    --
    local function run_handler(premature, opts)
         -- do some routine job in Lua just like a cron job
         if premature then
            return
         end
        
        local workerid = ngx.worker.id()
        local pkt
        
        local test1 = ngx.ctx.curr_conn
        self.curr_conn = {}
        
        -- reset sock
        if self.sock then
          self.sock:close()
          self.sock = false
        end
        
        -- new sock
        local sock, err1 = tcp()
        if not sock then
          return nil, "no socket -- workerid: " .. tostring(workerid) .. ", cid: " .. tostring(opts.cfg.id) .. ", cname: " .. opts.cfg.name .. ", host: " .. opts.cfg.host .. ", port: " .. tostring(opts.cfg.port)
        end
        self.sock = sock
        
        --
        local ok, err2 = self:connect(opts)
        if not ok then
          if self.enable_reconnect and self.reconnect_delay_seconds > 0 then
            -- reconnect
            ngx.timer.at(self.reconnect_delay_seconds, run_handler, opts)
          end
          return nil, err
        end
        
        if self.state ~= STATE_CONNECTED then
          return nil, "link broken -- workerid: " .. tostring(workerid) .. ", cid: " .. tostring(opts.cfg.id) .. ", cname: " .. opts.cfg.name .. ", host: " .. opts.cfg.host .. ", port: " .. tostring(opts.cfg.port)
        end

        self.curr_conn.upstream = sock

        --
        packet_type = opts.packet_type or 2
        if packet_type == 1 then
          packet_obj = packet1.new()
        else
          packet_obj = packet2.new()
        end
        self.curr_conn.packet_obj = packet_obj

        --
        while true do
          -- read packet
          local pkt, err = packet_obj:read(sock)
          if not pkt then
            ngx.say("failed to read packet: ", err)
            break
          end

          if opts.got_packet_cb then
            -- packet dispatcher
            opts.got_packet_cb(pkt)
          end
        end

        opts.disconnected_cb(s)
    end
  
    --
    ngx.timer.at(0, run_handler, opts)
end

return _M
