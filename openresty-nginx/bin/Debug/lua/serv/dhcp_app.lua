-- Localize
local cwd = (...):gsub("%.[^%.]+$", "") .. "."
local dhcpd = require(cwd .. "dhcp.server")

local _M = {
    _VERSION = "1.0.0.1",
    _DESCRIPTION = "It is the app entry ..."
}

local function dhcpd_callback(op, packet, options)
    return {
        yiaddr = "10.10.0.5",
        options = {
            subnet_mask = "255.255.255.0",
            broadcast_address = "10.10.10.255",
            router = {
                "10.10.10.1",
                "10.10.10.2"
            },
            domain_name = "openresty.com",
            hostname = "agentzh.openresty.com",
            address_lease_time = 86400,
            renewal_time = 3600,
            ipxe = {
                no_proxydhcp = 1
            }
        }
    }
end

--
function _M.serve()
    local ok, err = dhcpd.serve(dhcpd_callback)
    if not ok then
        ngx.log(ngx.ERR, err)
    end
end

return _M
