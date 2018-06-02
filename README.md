# Build openresty-win32 with vs2017

## Features

- Missing modules:
    - ngx_service
    - ngx_google_perftools_module
    - ngx_stream_geoip_module
    - ngx_http_geoip_module
    - ngx_http_degradation_module
    - ...

## Thirdparty Dependancy

+ jemalloc: https://github.com/jemalloc/jemalloc
+ libtiff: https://github.com/rouault/libtiff
+ libgd.lib: https://windows.php.net/downloads/php-sdk/deps/vc15/x86/
+ pgsql(libpg, openssl): https://www.enterprisedb.com/download-postgresql-binaries
+ perl: http://strawberryperl.com/releases.html
+ pcre: https://ftp.pcre.org/pub/pcre/