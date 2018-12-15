
/*
 * Copyright (C) Igor Sysoev
 * Copyright (C) Nginx, Inc.
 */


#include <ngx_config.h>
#include <ngx_core.h>
#include <ngx_event.h>
#include <ngx_connection.h>


static void ngx_drain_connectionsex(ngx_cycle_t *cycle);


ngx_connection_t *
ngx_get_connectionex(ngx_socket_t s, int family, int type, ngx_log_t *log)
{
    ngx_uint_t         instance;
    ngx_event_t       *rev, *wev;
    ngx_connection_t  *c;
    int                id; /* for debug */
    ngx_connection_t  *c_prev, *c_reuse; /* connection ready for reuse */
    int                iocp_bind;

    /* disable warning: Win32 SOCKET is u_int while UNIX socket is int */

    if (ngx_cycle->files && (ngx_uint_t)s >= ngx_cycle->files_n) {
        ngx_log_error(NGX_LOG_ALERT, log, 0,
            "the new socket has number %d, "
            "but only %ui files are available",
            s, ngx_cycle->files_n);
        return NULL;
    }

    c = NULL;
    c_prev = NULL;
    c_reuse = ngx_cycle->free_connections;

    while (c_reuse) {
        /* check if the disconnectex flag is off */
        if (c_reuse->read->evovlp.disconnectex_flag == 0) {
            /* ok, connection is reuseable */
            if (c_prev) {
                c_prev->data = c_reuse->data;
                c_reuse->data = ngx_cycle->free_connections;
            }
            c = c_reuse;
            break;
        }

        c_prev = c_reuse;
        c_reuse = c_reuse->data;
    }

    if (c == NULL) {
        ngx_drain_connectionsex((ngx_cycle_t *)ngx_cycle);
        c = ngx_cycle->free_connections;
    }

    if (c == NULL) {
        ngx_log_error(NGX_LOG_ALERT, log, 0,
            "%ui worker_connections are not enough",
            ngx_cycle->connection_n);

        return NULL;
    }

    if (s == (ngx_socket_t)-1) {
        /* check type */
        type = (type ? type : SOCK_STREAM);
        if (c->family == 0 || c->family != family
            || c->type == 0 || c->type != type) {

            if (c->fd != (ngx_socket_t)-1) {
                if (ngx_close_socket(c->fd) == -1) {
                    ngx_log_error(NGX_LOG_ALERT, log, ngx_socket_errno,
                                  ngx_close_socket_n "failed");
                    return NULL;
                }
            }
        }

        /* try reuse c->fd */
        if (c->fd == (ngx_socket_t)-1) {
            s = ngx_socket(family, type, 0);

            ngx_log_debug2(NGX_LOG_DEBUG_EVENT, log, 0, "%s socket %d",
                          (type == SOCK_STREAM) ? "stream" : "dgram", s);

            if (s == (ngx_socket_t)-1) {
                ngx_log_error(NGX_LOG_ALERT, log, ngx_socket_errno,
                              ngx_socket_n " failed");
                return NULL;
            }

            c->fd = s;
            c->family = family;
            c->type = type;
            c->iocp_bind = 0;
        }
    }
    else if (s == 0) {
        /* just keep "c->fd" as it was */
    }
    else {
        /* we should use "s", close c->fd */
        if (c->fd != (ngx_socket_t)-1) {
            if (ngx_close_socket(c->fd) == -1) {
                ngx_log_error(NGX_LOG_ALERT, log, ngx_socket_errno,
                    ngx_close_socket_n "failed");
                return NULL;
            }
        }

        c->fd = s;
        c->family = family;
        c->type = type;
        c->iocp_bind = 0;
    }

    ngx_cycle->free_connections = c->data;
    ngx_cycle->free_connection_n--;

    if (ngx_cycle->files && ngx_cycle->files[s] == NULL) {
        ngx_cycle->files[s] = c;
    }

    s = c->fd;
    family = c->family;
    type = c->type;
    iocp_bind = c->iocp_bind;
    rev = c->read;
    wev = c->write;
    
    /* the "id" is for debug */
    id = c->id;

    ngx_memzero(c, sizeof(ngx_connection_t));
    c->id = id;

    c->fd = s;
    c->family = family;
    c->iocp_bind = iocp_bind;
    c->type = type;
    c->read = rev;
    c->write = wev;

    c->log = log;

    instance = rev->instance;

    ngx_memzero(rev, sizeof(ngx_event_t));
    ngx_memzero(wev, sizeof(ngx_event_t));

    rev->instance = !instance;
    wev->instance = !instance;

    rev->index = NGX_INVALID_INDEX;
    wev->index = NGX_INVALID_INDEX;

    rev->data = c;
    wev->data = c;

    wev->write = 1;

#if (NGX_DEBUG)
    // debug
    output_malloc_stats(log);
#endif
    return c;
}


static void
ngx_drain_connectionsex(ngx_cycle_t *cycle)
{
    ngx_uint_t         i, n;
    ngx_queue_t       *q;
    ngx_connection_t  *c;

    n = ngx_max(ngx_min(32, cycle->reusable_connections_n / 8), 1);

    for (i = 0; i < n; i++) {
        if (ngx_queue_empty(&cycle->reusable_connections_queue)) {
            break;
        }

        q = ngx_queue_last(&cycle->reusable_connections_queue);
        c = ngx_queue_data(q, ngx_connection_t, queue);

        ngx_log_debug0(NGX_LOG_DEBUG_CORE, c->log, 0,
                       "reusing connection");

        c->close = 1;
        c->read->handler(c->read);
    }
}
