local _M = {
    _VERSION = "1.0",
    _DESCRIPTION  = "proxy pass for redis request ...",
}

--
local redis = require "resty.redis"
local assert = assert
local print = print
local rawget = rawget
local setmetatable = setmetatable
local tonumber = tonumber
local str_byte = string.byte
local str_gmatch = string.gmatch
local str_sub = string.sub
local str_upper = string.upper

--
local function parse_request(sock)
    local line, err = sock:receive()
    if not line then
        return nil, err
    end

    local prefix = str_byte(line)
    if prefix == 42 then -- char '*'
        local result = {}
        local num = tonumber(str_sub(line, 2))
        if num <= 0 then
            return nil, "Wrong protocol format"
        end

        for i = 1, num do
            local res, err = parse_request(sock)
            if res == nil then
                return nil, err
            end

            result[i] = res
        end
        return result
    elseif prefix == 36 then -- char '$'
        local size = tonumber(str_sub(line, 2))
        if size < 0 then
            return nil, "Wrong protocol format"
        end

        local result, err = sock:receive(size)
        if not result then
            return nil, err
        end

        local crlf, err2 = sock:receive(2)
        if not crlf then
            return nil, err2
        end
        return result
    end

    -- inline
    local result = {}
    for res in str_gmatch(line, "%S+") do
        result[#result + 1] = res
    end
    return result
end

--
local function fetch_response(sock)
    local line, err = sock:receive()
    if not line then
        return nil, err
    end

    local result = {line, "rn"}
    local prefix = str_byte(line)
    if prefix == 42 then -- char '*'
        local num = tonumber(str_sub(line, 2))
        if num <= 0 then
            return result
        end

        for i = 1, num do
            local res, err = fetch_response(sock)
            if res == nil then
                return nil, err
            end

            for x = 1, #res do
                result[#result + 1] = res[x]
            end
        end
    elseif prefix == 36 then -- char '$'
        local size = tonumber(str_sub(line, 2))

        if size < 0 then
            return result
        end

        local res, err = sock:receive(size)

        if not res then
            return nil, err
        end

        local crlf, err = sock:receive(2)

        if not crlf then
            return nil, err
        end

        result[#result + 1] = res

        result[#result + 1] = crlf
    end

    return result
end

--
local function build_data(value)
    local result = {"*", #value, "rn"}

    for i = 1, #value do
        local v = value[i]
        result[#result + 1] = "$"
        result[#result + 1] = #v
        result[#result + 1] = "rn"
        result[#result + 1] = v
        result[#result + 1] = "rn"
    end

    return result
end

--
local function status_reply(message)
    return "+" .. message .. "rn"
end

--
local function command_args(request)
    local command = request[1]

    command = str_upper(command)
    local args = {}
    for i = 2, #request do
        args[#args + 1] = request[i]
    end
    return command, args
end

--
local function exit(err)
    ngx.log(ngx.NOTICE, err)

    return ngx.exit(ngx.ERROR)
end

--
function _M.new(self, config)
    local t = {
        _ip = config.ip or "127.0.0.1",
        _port = config.port or 6379,
        _timeout = config.timeout or 100000,
        _size = config.size or 10,
        _auth = config.auth
    }

    return setmetatable(t, {__index = _M})
end

function _M.run(self)
    local ip = self._ip
    local port = self._port
    local timeout = self._timeout
    local size = self._size
    local auth = self._auth
    local red = redis:new()

    local ok, err = red:connect(ip, port)
    if not ok then
        return exit(err)
    end

    if auth then
        local times = assert(red:get_reused_times())
        if times == 0 then
            local ok, err = red:auth(auth)

            if not ok then
                return exit(err)
            end
        end
    end

    local database = 0
    local transactional = false
    local upstream_sock = rawget(red, "_sock")
    local downstream_sock = assert(ngx.req.socket(true))

    while true do
        local request, err = parse_request(downstream_sock)
        if not request then
            if err == "client aborted" then
                break
            end

            return exit(err)
        end

        local command, args = command_args(request)
        if command == "QUIT" then
            downstream_sock:send(status_reply("OK"))

            break
        end

        upstream_sock:send(build_data(request))

        local response, err = fetch_response(upstream_sock)
        if not response then
            return exit(err)
        end

        if command == "SELECT" then
            database = tonumber(args[1])
        elseif command == "MULTI" then
            transactional = true
        elseif command == "EXEC" or command == "DISCARD" then
            transactional = false
        end

        downstream_sock:send(response)
    end

    if database ~= 0 then
        red:select(0)
    end

    if transactional then
        red:discard()
    end

    red:set_keepalive(timeout, size)
end

return _M
