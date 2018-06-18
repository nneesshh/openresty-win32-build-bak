
/*
 * Copyright (C) Igor Sysoev
 * Copyright (C) Nginx, Inc.
 */


#include <ngx_config.h>
#include <ngx_core.h>
#include <ngx_event.h>


ssize_t
ngx_wsasend(ngx_connection_t *c, u_char *buf, size_t size)
{
    int           n;
    u_long        sent;
    ngx_err_t     err;
    ngx_event_t  *wev;
    WSABUF        wsabuf;

    wev = c->write;

    if (!wev->ready) {
        return NGX_AGAIN;
    }

    /*
     * WSABUF must be 4-byte aligned otherwise
     * WSASend() will return undocumented WSAEINVAL error.
     */

    wsabuf.buf = (char *) buf;
    wsabuf.len = size;

    sent = 0;

    n = WSASend(c->fd, &wsabuf, 1, &sent, 0, NULL, NULL);

    ngx_log_debug4(NGX_LOG_DEBUG_EVENT, c->log, 0,
                   "WSASend: fd:%d, %d, %ul of %uz", c->fd, n, sent, size);

    if (n == 0) {
        if (sent < size) {
            wev->ready = 0;
        }

        c->sent += sent;

        return sent;
    }

    err = ngx_socket_errno;

    if (err == WSAEWOULDBLOCK) {
        ngx_log_debug0(NGX_LOG_DEBUG_EVENT, c->log, err, "WSASend() not ready");
        wev->ready = 0;
        return NGX_AGAIN;
    }

    wev->error = 1;
    ngx_connection_error(c, err, "WSASend() failed");

    return NGX_ERROR;
}


ssize_t
ngx_overlapped_wsasend(ngx_connection_t *c, u_char *buf, size_t size)
{
    int               n;
    u_long            sent;
    ngx_err_t         err;
    ngx_event_t      *wev;
    LPWSAOVERLAPPED   ovlp;
    WSABUF            wsabuf;

    wev = c->write;

    if (!wev->ready) {
        return NGX_AGAIN;
    }

    ngx_log_debug1(NGX_LOG_DEBUG_EVENT, c->log, 0,
                   "wev->complete: %d", wev->complete);

    if (!wev->complete) {

        /* post the overlapped WSASend() */

        /*
         * WSABUFs must be 4-byte aligned otherwise
         * WSASend() will return undocumented WSAEINVAL error.
         */

        wsabuf.buf = (char *) buf;
        wsabuf.len = size;

        sent = 0;

        ovlp = (LPWSAOVERLAPPED) &c->write->ovlp;
        ngx_memzero(ovlp, sizeof(WSAOVERLAPPED));

        n = WSASend(c->fd, &wsabuf, 1, &sent, 0, ovlp, NULL);

        ngx_log_debug4(NGX_LOG_DEBUG_EVENT, c->log, 0,
                       "WSASend: fd:%d, %d, %ul of %uz", c->fd, n, sent, size);

#if (NGX_DEBUG)
        // debug
        if (sent > 65535) {
            printf("error sent(%ld) -- fd(%d)!!!!\n", sent, c->fd);
        }
        printf("\nngx_overlapped_wsasend(): post event WSASend() of sent(%ld) on -- c(%d)fd(%d)destroyed(%d)_r(0x%08x)w(0x%08x)c(0x%08x) ... wev(0x%08x)data(0x%08x)\n",
            sent,
            c->id, c->fd, c->destroyed, (uintptr_t)c->read, (uintptr_t)c->write, (uintptr_t)c, (uintptr_t)wev, (uintptr_t)wev->data);
#endif

        wev->complete = 0;

        if (n == 0) {
            if (ngx_event_flags & NGX_USE_IOCP_EVENT) {

                /*
                 * if a socket was bound with I/O completion port then
                 * GetQueuedCompletionStatus() would anyway return its status
                 * despite that WSASend() was already complete
                 */

                wev->active = 1;
                return NGX_AGAIN;
            }

            if (sent < size) {
                wev->ready = 0;
            }

            c->sent += sent;

            return sent;
        }

        err = ngx_socket_errno;

        if (err == WSA_IO_PENDING) {
            ngx_log_debug0(NGX_LOG_DEBUG_EVENT, c->log, err,
                           "WSASend() posted");
            wev->active = 1;
            return NGX_AGAIN;
        }

        wev->error = 1;
        ngx_connection_error(c, err, "WSASend() failed");

        return NGX_ERROR;
    }

    /* the overlapped WSASend() complete */

    wev->complete = 0;
    wev->active = 0;

    if (ngx_event_flags & NGX_USE_IOCP_EVENT) {
        sent = wev->available;

    } else {
        if (WSAGetOverlappedResult(c->fd, (LPWSAOVERLAPPED) &wev->ovlp,
                                   &sent, 0, NULL)
            == 0)
        {
            ngx_connection_error(c, ngx_socket_errno,
                           "WSASend() or WSAGetOverlappedResult() failed");

            return NGX_ERROR;
        }
    }

    ngx_log_debug3(NGX_LOG_DEBUG_EVENT, c->log, 0,
                   "WSAGetOverlappedResult: fd:%d, %ul of %uz",
                   c->fd, sent, size);

    if (sent < size) {
        wev->ready = 0;
    }

    c->sent += sent;

    return sent;
}
