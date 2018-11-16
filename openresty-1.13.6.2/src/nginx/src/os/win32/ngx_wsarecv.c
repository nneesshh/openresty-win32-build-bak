
/*
 * Copyright (C) Igor Sysoev
 * Copyright (C) Nginx, Inc.
 */


#include <ngx_config.h>
#include <ngx_core.h>
#include <ngx_event.h>


ssize_t
ngx_wsarecv(ngx_connection_t *c, u_char *buf, size_t size)
{
    int           rc;
    u_long        bytes, flags;
    WSABUF        wsabuf[1];
    ngx_err_t     err;
    ngx_int_t     n;
    ngx_event_t  *rev;

    wsabuf[0].buf = (char *) buf;
    wsabuf[0].len = size;
    flags = 0;
    bytes = 0;

    rc = WSARecv(c->fd, wsabuf, 1, &bytes, &flags, NULL, NULL);

    ngx_log_debug4(NGX_LOG_DEBUG_EVENT, c->log, 0,
                   "WSARecv: fd:%d rc:%d %ul of %z", c->fd, rc, bytes, size);

    rev = c->read;

    if (rc == -1) {
        rev->ready = 0;
        err = ngx_socket_errno;

        if (err == WSAEWOULDBLOCK) {
            ngx_log_debug0(NGX_LOG_DEBUG_EVENT, c->log, err,
                           "WSARecv() not ready");
            return NGX_AGAIN;
        }

        n = ngx_connection_error(c, err, "WSARecv() failed");

        if (n == NGX_ERROR) {
            rev->error = 1;
        }

        return n;
    }

    if (bytes < size) {
        rev->ready = 0;
    }

    if (bytes == 0) {
        rev->eof = 1;
    }

    return bytes;
}


ssize_t
ngx_overlapped_wsarecv(ngx_connection_t *c, u_char *buf, size_t size)
{
    int               rc;
    u_long            bytes, flags;
    WSABUF            wsabuf[1];
    ngx_err_t         err;
    ngx_int_t         n;
    ngx_event_t      *rev;
    LPWSAOVERLAPPED   ovlp;

    rev = c->read;

    if (!rev->ready) {
        ngx_log_error(NGX_LOG_ERR, c->log, 0, "ngx_overlapped_wsarecv(): second wsa post");
        return NGX_ERROR;
    }

    ngx_log_debug1(NGX_LOG_DEBUG_EVENT, c->log, 0,
                   "rev->complete: %d", rev->complete);

    if (rev->complete) {
        rev->complete = 0;

        if (ngx_event_flags & NGX_USE_IOCP_EVENT) {

            ngx_log_debug3(NGX_LOG_DEBUG_EVENT, c->log, 0,
                           "WSARecv ovlp: fd:%d %ul of %z",
                           c->fd, rev->available, size);

            return rev->available;
        }

        if (WSAGetOverlappedResult(c->fd, (LPWSAOVERLAPPED) &rev->ovlp,
                                   &bytes, 0, NULL)
            == 0)
        {
            ngx_connection_error(c, ngx_socket_errno,
                               "WSARecv() or WSAGetOverlappedResult() failed");
            return NGX_ERROR;
        }

        ngx_log_debug3(NGX_LOG_DEBUG_EVENT, c->log, 0,
                       "WSARecv: fd:%d %ul of %z", c->fd, bytes, size);

        return bytes;
    }

    ovlp = (LPWSAOVERLAPPED) &rev->ovlp;
    ngx_memzero(ovlp, sizeof(WSAOVERLAPPED));
    wsabuf[0].buf = (char *) buf;
    wsabuf[0].len = size;
    flags = 0;
    bytes = 0;

    rc = WSARecv(c->fd, wsabuf, 1, &bytes, &flags, ovlp, NULL);

#if (NGX_DEBUG)
    // debug
    output_debug_string("\nngx_overlapped_wsarecv(): post event WSARecv() with buffer(0x%08x)(%d)_bytes(%ld) on -- c(%d)fd(%d)destroyed(%d)_r(0x%08x)w(0x%08x)c(0x%08x) ... w(%d)\n", 
        (uintptr_t)buf, (int)size, bytes,
        c->id, c->fd, c->destroyed, (uintptr_t)c->read, (uintptr_t)c->write, (uintptr_t)c, rev->write);
#endif

    ngx_log_debug4(NGX_LOG_DEBUG_EVENT, c->log, 0,
                   "WSARecv ovlp: fd:%d rc:%d %ul of %z",
                   c->fd, rc, bytes, size);

    if (rc == -1) {
        err = ngx_socket_errno;
        if (err == WSA_IO_PENDING) {
            rev->ready = 0; /* read event already posted and still in processing, don't post again before response */
            rev->active = 1;
            ngx_log_debug0(NGX_LOG_DEBUG_EVENT, c->log, err,
                           "WSARecv() posted");
            return NGX_AGAIN;
        }

#if (NGX_DEBUG)
		// debug
		output_debug_string("\nngx_overlapped_wsarecv(): errno=(%llu)!!!!\n",
			(uint64_t)err);
#endif

        n = ngx_connection_error(c, err, "WSARecv() failed");

        if (n == NGX_ERROR) {
            rev->error = 1;
        }

        return n;
    }

    if (ngx_event_flags & NGX_USE_IOCP_EVENT) {

        /*
         * if a socket was bound with I/O completion port
         * then GetQueuedCompletionStatus() would anyway return its status
         * despite that WSARecv() was already complete
         */

        rev->ready = 0; /* read event posted, don't post again before response */
        rev->active = 1;
        return NGX_AGAIN;
    }

    if (bytes == 0) {
        rev->eof = 1;
        rev->ready = 0;

    } else {
        rev->ready = 1;
    }

    rev->active = 0;

    return bytes;
}
