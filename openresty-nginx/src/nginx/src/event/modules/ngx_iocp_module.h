
/*
 * Copyright (C) Igor Sysoev
 * Copyright (C) Nginx, Inc.
 */


#ifndef _NGX_IOCP_MODULE_H_INCLUDED_
#define _NGX_IOCP_MODULE_H_INCLUDED_


typedef struct {
    int  threads;
    int  post_acceptex;
    int  acceptex_read;
} ngx_iocp_conf_t;


extern ngx_module_t  ngx_iocp_module;

extern ngx_int_t     ngx_iocp_create_port(ngx_event_t *ev, ngx_uint_t key);

#endif /* _NGX_IOCP_MODULE_H_INCLUDED_ */
