use lib 'lib';
use Test::Nginx::Socket::Lua;
use Cwd qw(cwd);

repeat_each(2);

plan tests => repeat_each() * (blocks() * 5 + 2);

my $pwd = cwd();

$ENV{TEST_NGINX_HOTLOOP} ||= 9;

add_block_preprocessor(sub {
    my $block = shift;

    my $http_config = $block->http_config || '';
    my $init_by_lua_block = $block->init_by_lua_block || 'require "resty.core"';

    $http_config .= <<_EOC_;

    lua_package_path "$pwd/lib/?.lua;../lua-resty-lrucache/lib/?.lua;;";
    init_by_lua_block {
        local verbose = false
        if verbose then
            local dump = require "jit.dump"
            dump.on("b", "$Test::Nginx::Util::ErrLogFile")
        else
            local v = require "jit.v"
            v.on("$Test::Nginx::Util::ErrLogFile")
        end

        $init_by_lua_block

        local jit = require "jit"
        jit.opt.start("hotloop=$ENV{TEST_NGINX_HOTLOOP}")
    }
_EOC_

    $block->set_value("http_config", $http_config);

    if (!defined $block->error_log) {
        my $no_error_log = <<_EOC_;
[error]
[alert]
[emerg]
-- NYI:
stitch
_EOC_

        $block->set_value("no_error_log", $no_error_log);
    }

    if (!defined $block->request) {
        $block->set_value("request", "GET /t");
    }

});

check_accum_error_log();
run_tests();

__DATA__

=== TEST 1: sanity
--- config
    location /t {
        content_by_lua_block {
            local s = ndk.set_var.set_escape_uri(" :")
            local r = ndk.set_var.set_unescape_uri("a%20b")
            ngx.say(s)
            ngx.say(r)

            local set_escape_uri = ndk.set_var.set_escape_uri
            local set_unescape_uri = ndk.set_var.set_unescape_uri
            ngx.say(set_escape_uri(" :"))
            ngx.say(set_unescape_uri("a%20b"))

            local res
            for i = 1, $TEST_NGINX_HOTLOOP + 2 do
                res = set_escape_uri(" :")
            end

            for i = 1, $TEST_NGINX_HOTLOOP + 2 do
                res = set_unescape_uri("a%20b")
            end
        }
    }
--- error_log eval
qr/\[TRACE\s+\d+ content_by_lua\(nginx\.conf:\d+\):13 loop\]/,
qr/\[TRACE\s+\d+ content_by_lua\(nginx\.conf:\d+\):17 loop\]/
--- no_error_log
[error]
[alert]
[emerg]
-- NYI:
stitch
--- response_body
%20%3A
a b
%20%3A
a b



=== TEST 2: directive not found
--- config
    location /t {
        content_by_lua_block {
            local s = ndk.set_var.set_escape_uri_blah_blah(" :")
            ngx.say(s)
        }
    }
--- response_body_like: 500 Internal Server Error
--- error_code: 500
--- error_log
ndk.set_var: directive "set_escape_uri_blah_blah" not found or does not use ndk_set_var_value



=== TEST 3: ndk.set_var initialize ngx_http_variable_value_t variable properly
--- config
    location /t {
        content_by_lua_block {
            local version = '2011.10.13+0000'
            local e_version = ndk.set_var.set_encode_base32(version)
            local s_version= ndk.set_var.set_quote_sql_str(version)
            ngx.say(e_version)
            ngx.say(s_version)
        }
    }
--- response_body
68o32c9e64o2sc9j5co30c1g
'2011.10.13+0000'



=== TEST 4: set directive not allowed
--- config
    location /t {
        content_by_lua_block {
            ndk.set_var.set_escape_uri = "hack it"
        }
    }
--- response_body_like: 500 Internal Server Error
--- error_code: 500
--- error_log
not allowed



=== TEST 5: call directive failed
--- config
    location /t {
        content_by_lua_block {
            ndk.set_var.set_decode_hex('a')
        }
    }
--- response_body_like: 500 Internal Server Error
--- error_code: 500
--- error_log
calling directive set_decode_hex failed with code -1



=== TEST 6: convert directive type to string
--- config
    location /t {
        content_by_lua_block {
            ndk.set_var[1]()
        }
    }
--- response_body_like: 500 Internal Server Error
--- error_code: 500
--- error_log
ndk.set_var: directive "1" not found or does not use ndk_set_var_value



=== TEST 7: convert directive argument to string
--- config
    location /t {
        content_by_lua_block {
            local s = ndk.set_var.set_escape_uri(1)
            ngx.say(s)
        }
    }
--- response_body
1



=== TEST 8: call in set_by_lua
--- config
    location /t {
        set_by_lua_block $s {
            return ndk.set_var.set_escape_uri(" :")
        }
        echo $s;
    }
--- response_body
%20%3A



=== TEST 9: call in timer
--- config
    location /t {
        content_by_lua_block {
            ngx.timer.at(0, function()
                local s = ndk.set_var.set_escape_uri(" :")
                ngx.log(ngx.WARN, "s = ", s)
            end)
            ngx.sleep(0.01)
        }
    }
--- error_log
s = %20%3A
--- no_error_log
[error]



=== TEST 10: call in header_filter_by_lua
--- config
    location /t {
        content_by_lua_block {
            ngx.send_headers()
            ngx.say(package.loaded.s)
        }
        header_filter_by_lua_block {
            package.loaded.s = ndk.set_var.set_escape_uri(" :")
        }
    }
--- response_body
%20%3A



=== TEST 11: call in log_by_lua
--- config
    location /t {
        echo ok;
        log_by_lua_block {
            local s = ndk.set_var.set_escape_uri(" :")
            ngx.log(ngx.WARN, "s = ", s)
        }
    }
--- response_body
ok
--- error_log
s = %20%3A
--- no_error_log
[error]



=== TEST 12: call in init_worker_by_lua
--- http_config
    init_worker_by_lua_block {
        package.loaded.s = ndk.set_var.set_escape_uri(" :")
    }
--- config
    location /t {
        content_by_lua_block {
            ngx.say(package.loaded.s)
        }
    }
--- response_body
%20%3A
