# vim:set sts=4 ts=4 sw=4 et fdm=marker:
use Test::Nginx::Socket::Lua;
use t::Util;

our $HttpConfig = $t::Util::HttpConfig;

master_on();

plan tests => repeat_each() * blocks() * 3 + 4;

run_tests();

__DATA__

=== TEST 1: is_valid() PCRE
--- http_config eval: $::HttpConfig
--- config
    location /t {
        content_by_lua_block {
            local uuid = require 'resty.jit-uuid'
            local tests = {
                -- v4
                'cbb297c0-a956-486d-ad1d-f9b42df9465a',
                '5014127b-4189-494d-b36f-9191cb39bf20',
                '6de59524-0091-48fa-9c13-67908ff5e63c',
                '24b0b2cf-4481-4f41-88b3-aac0a941d756',

                -- v3
                '3db7a435-8c56-359d-a563-1b69e6802c78',
                'e8d3eeba-7723-3b72-bbc5-8f598afa6773',

                -- upper-case
                'AC4FAD5A-98A7-45EC-9C4B-5BCB53706A86',
                '83BEA132-0130-4C54-911F-F5F168A3C40E',

                '24b0b2cf-4481-4f41-38b3-aac0a941d756', -- invalid variant
                '24b0b2cf-4481-4f41-88b3-aac0a941d75',
                '24b0b2cf44814f4188b3aac0a941d756',
                '24b&b2cf-4481-4f41-88b3-aac0a941d756',
                '24b0b2cf-4481-4f41-88b3_aac0a941d756'
            }

            for i = 1, #tests do
                ngx.say(uuid.is_valid(tests[i]))
            end

            ngx.say(uuid.is_valid())
        }
    }
--- request
GET /t
--- response_body
true
true
true
true
true
true
true
true
false
false
false
false
false
false
--- no_error_log
[error]



=== TEST 2: is_valid() no PCRE
--- http_config eval: $::HttpConfig
--- config
    location /t {
        content_by_lua_block {
            ngx.config.nginx_configure = function() return '' end
            local uuid = require 'resty.jit-uuid'
            local tests = {
                'cbb297c0-a956-486d-ad1d-f9b42df9465a',
                '5014127b-4189-494d-b36f-9191cb39bf20',
                '6de59524-0091-48fa-9c13-67908ff5e63c',
                '24b0b2cf-4481-4f41-88b3-aac0a941d756',

                -- v3
                '3db7a435-8c56-359d-a563-1b69e6802c78',
                'e8d3eeba-7723-3b72-bbc5-8f598afa6773',

                -- upper-case
                'AC4FAD5A-98A7-45EC-9C4B-5BCB53706A86',
                '83BEA132-0130-4C54-911F-F5F168A3C40E',

                '24b0b2cf-4481-4f41-38b3-aac0a941d756', -- invalid variant
                '24b0b2cf-4481-4f41-88b3-aac0a941d75',
                '24b0b2cf44814f4188b3aac0a941d756',
                '24b&b2cf-4481-4f41-88b3-aac0a941d756',
                '24b0b2cf-4481-4f41-88b3_aac0a941d756'
            }

            for i = 1, #tests do
                ngx.say(uuid.is_valid(tests[i]))
            end

            ngx.say(uuid.is_valid())
        }
    }
--- request
GET /t
--- response_body
true
true
true
true
true
true
true
true
false
false
false
false
false
false
--- no_error_log
[error]



=== TEST 3: is_valid() JIT compiles with invalid
--- http_config eval: $t::Util::HttpConfigJit
--- config
    location /t {
        content_by_lua_block {
            local uuid = require 'resty.jit-uuid'

            for _ = 1, 100 do
                uuid.is_valid("")
            end
        }
    }
--- request
GET /t
--- response_body

--- error_log eval
qr/\[TRACE   \d+ content_by_lua\(nginx\.conf:\d+\):4 loop\]/
--- no_error_log
[error]
-- NYI:



=== TEST 4: is_valid() JIT compiles with valid
--- http_config eval: $t::Util::HttpConfigJit
--- config
    location /t {
        content_by_lua_block {
            local uuid = require 'resty.jit-uuid'

            for _ = 1, 100 do
                uuid.is_valid("cbb297c0-a956-486d-ad1d-f9b42df9465a")
            end
        }
    }
--- request
GET /t
--- response_body

--- error_log eval
qr/\[TRACE   \d+ content_by_lua\(nginx\.conf:\d+\):4 loop\]/
--- no_error_log
[error]
-- NYI:
