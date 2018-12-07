
/*
 * Copyright (C) Igor Sysoev
 * Copyright (C) Nginx, Inc.
 */


#include <ngx_config.h>
#include <ngx_core.h>
#include <ngx_event.h>

#include <ngx_event_connect.h>


ngx_int_t
ngx_event_connect_peerex(ngx_peer_connection_t *pc)
{
    int                rc, type, value;
#if (NGX_HAVE_IP_BIND_ADDRESS_NO_PORT || NGX_LINUX)
    in_port_t          port;
#endif

    ngx_err_t          err;

    ngx_socket_t       s;
    ngx_event_t       *rev, *wev;
    ngx_connection_t  *c;

    struct sockaddr_in  addr0;

    rc = pc->get(pc, pc->data);
    if (rc != NGX_OK) {
        return rc;
    }

    type = (pc->type ? pc->type : SOCK_STREAM);

    s = ngx_socket(pc->sockaddr->sa_family, type, 0);

    ngx_log_debug2(NGX_LOG_DEBUG_EVENT, pc->log, 0, "%s socket %d",
                   (type == SOCK_STREAM) ? "stream" : "dgram", s);

    if (s == (ngx_socket_t) -1) {
        ngx_log_error(NGX_LOG_ALERT, pc->log, ngx_socket_errno,
                      ngx_socket_n " failed");
        return NGX_ERROR;
    }


    c = ngx_get_connection(s, pc->log);

    if (c == NULL) {
        if (ngx_close_socket(s) == -1) {
            ngx_log_error(NGX_LOG_ALERT, pc->log, ngx_socket_errno,
                          ngx_close_socket_n " failed");
        }

        return NGX_ERROR;
    }

    c->type = type;

    if (pc->rcvbuf) {
        if (setsockopt(s, SOL_SOCKET, SO_RCVBUF,
                       (const void *) &pc->rcvbuf, sizeof(int)) == -1)
        {
            ngx_log_error(NGX_LOG_ALERT, pc->log, ngx_socket_errno,
                          "setsockopt(SO_RCVBUF) failed");
            goto failed;
        }
    }

    if (pc->so_keepalive) {
        value = 1;

        if (setsockopt(s, SOL_SOCKET, SO_KEEPALIVE,
                       (const void *) &value, sizeof(int))
            == -1)
        {
            ngx_log_error(NGX_LOG_ALERT, pc->log, ngx_socket_errno,
                          "setsockopt(SO_KEEPALIVE) failed, ignored");
        }
    }

    if (ngx_nonblocking(s) == -1) {
        ngx_log_error(NGX_LOG_ALERT, pc->log, ngx_socket_errno,
                      ngx_nonblocking_n " failed");

        goto failed;
    }

    if (pc->local) {

#if (NGX_HAVE_TRANSPARENT_PROXY)
        if (pc->transparent) {
            if (ngx_event_connect_set_transparent(pc, s) != NGX_OK) {
                goto failed;
            }
        }
#endif

#if (NGX_HAVE_IP_BIND_ADDRESS_NO_PORT || NGX_LINUX)
        port = ngx_inet_get_port(pc->local->sockaddr);
#endif

#if (NGX_HAVE_IP_BIND_ADDRESS_NO_PORT)

        if (pc->sockaddr->sa_family != AF_UNIX && port == 0) {
            static int  bind_address_no_port = 1;

            if (bind_address_no_port) {
                if (setsockopt(s, IPPROTO_IP, IP_BIND_ADDRESS_NO_PORT,
                               (const void *) &bind_address_no_port,
                               sizeof(int)) == -1)
                {
                    err = ngx_socket_errno;

                    if (err != NGX_EOPNOTSUPP && err != NGX_ENOPROTOOPT) {
                        ngx_log_error(NGX_LOG_ALERT, pc->log, err,
                                      "setsockopt(IP_BIND_ADDRESS_NO_PORT) "
                                      "failed, ignored");

                    } else {
                        bind_address_no_port = 0;
                    }
                }
            }
        }

#endif

#if (NGX_LINUX)

        if (pc->type == SOCK_DGRAM && port != 0) {
            int  reuse_addr = 1;

            if (setsockopt(s, SOL_SOCKET, SO_REUSEADDR,
                           (const void *) &reuse_addr, sizeof(int))
                 == -1)
            {
                ngx_log_error(NGX_LOG_ALERT, pc->log, ngx_socket_errno,
                              "setsockopt(SO_REUSEADDR) failed");
                goto failed;
            }
        }

#endif

        if (bind(s, pc->local->sockaddr, pc->local->socklen) == -1) {
            ngx_log_error(NGX_LOG_CRIT, pc->log, ngx_socket_errno,
                          "bind(%V) failed", &pc->local->name);

            goto failed;
        }
    }

    if (type == SOCK_STREAM) {
        c->recv = ngx_recv;
        c->send = ngx_send;
        c->recv_chain = ngx_recv_chain;
        c->send_chain = ngx_send_chain;

        c->sendfile = 1;

        if (pc->sockaddr->sa_family == AF_UNIX) {
            c->tcp_nopush = NGX_TCP_NOPUSH_DISABLED;
            c->tcp_nodelay = NGX_TCP_NODELAY_DISABLED;

#if (NGX_SOLARIS)
            /* Solaris's sendfilev() supports AF_NCA, AF_INET, and AF_INET6 */
            c->sendfile = 0;
#endif
        }

    } else { /* type == SOCK_DGRAM */
        c->recv = ngx_udp_recv;
        c->send = ngx_send;
        c->send_chain = ngx_udp_send_chain;
    }

    c->log_error = pc->log_error;

    rev = c->read;
    wev = c->write;

    rev->log = pc->log;
    wev->log = pc->log;

    pc->connection = c;

    c->number = ngx_atomic_fetch_add(ngx_connection_counter, 1);

    if (ngx_add_conn) {
        if (ngx_add_conn(c) == NGX_ERROR) {
            goto failed;
        }
    }

    ngx_log_debug3(NGX_LOG_DEBUG_EVENT, pc->log, 0,
                   "connect to %V, fd:%d #%uA", pc->name, s, c->number);

#if (NGX_DEBUG)
    // debug
    output_debug_string(c, "\nngx_event_connect_peerex(): c(%d)fd(%d)destroyed(%d)_r(0x%08x)w(0x%08x)c(0x%08x)\n",
        c->id, c->fd, c->destroyed, (uintptr_t)c->read, (uintptr_t)c->write, (uintptr_t)c);
#endif

    rev->evovlp.event = rev;
    wev->evovlp.event = wev;

    rev->ready = 1;
    wev->ready = 1;

    if (ngx_iocp_create_port(rev, NGX_IOCP_CONNECT) == NGX_ERROR) {
        goto failed;
    }

    /* ConnectEx requires the socket to be initially bound. */
    ngx_memzero(&addr0, sizeof(addr0));
    addr0.sin_family = AF_INET;
    addr0.sin_addr.s_addr = INADDR_ANY;
    addr0.sin_port = 0;

    rc = bind(s, (SOCKADDR*)&addr0, sizeof(addr0));
    if (rc != 0) {
        err = ngx_socket_errno;
        ngx_log_error(NGX_LOG_ERR, c->log, err, "bind() to %V failed",
            pc->name);

        goto failed;
    }

    if (ngx_connectex(s,
        pc->sockaddr,
        pc->socklen,
        NULL,
        0,
        NULL,
        (LPOVERLAPPED)&rev->evovlp)
        == 0)
    {
        err = ngx_socket_errno;
        if (err != WSA_IO_PENDING) {

            ngx_log_error(NGX_LOG_ERR, c->log, err, "connect() to %V failed",
                pc->name);

            goto failed;
        }
    }

    ngx_log_debug1(NGX_LOG_DEBUG_EVENT, pc->log, ngx_socket_errno,
        "connect(): %d", rc);

    /* use rev to wait for connectex result */
    rev->evovlp.connectex_flag = 1;
    rev->evovlp.recv_mem_lock_flag = 1; /* always 1 when connectex */
    rev->ready = 0;

    wev->evovlp.connectex_flag = 1;
    wev->evovlp.recv_mem_lock_flag = 0; /* always 0 because wev ingnore this flag */

    return NGX_OK;

failed:

    ngx_close_connection(c);
    pc->connection = NULL;

    return NGX_ERROR;
}
