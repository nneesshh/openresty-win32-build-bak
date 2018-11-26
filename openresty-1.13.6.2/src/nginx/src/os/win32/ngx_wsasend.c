
/*
 * Copyright (C) Igor Sysoev
 * Copyright (C) Nginx, Inc.
 */


#include <ngx_config.h>
#include <ngx_core.h>
#include <ngx_event.h>


#define NGX_WSABUF_SIZE_MAX  4096
#define NGX_WSABUFS          16


ssize_t
ngx_wsasend(ngx_connection_t *c, u_char *buf, size_t size)
{
    int           n;
    u_long        sent;
    ngx_err_t     err;
    ngx_event_t  *wev;
    WSABUF        wsabuf;

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

    wev = c->write;

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
    int               rc;
    u_long            remain, drain, sent;
    ngx_err_t         err;
    ngx_event_t      *wev;
    ngx_array_t       vec;
    LPWSAOVERLAPPED   ovlp;
    LPWSABUF          wsabuf;
    WSABUF            wsabufs[NGX_WSABUFS];

    ngx_chain_t      *cl, *ln, **tail, *chain;

    wev = c->write;

    ngx_log_debug1(NGX_LOG_DEBUG_EVENT, c->log, 0,
                   "wev->complete: %d", wev->complete);

    if (wev->complete) {
        wev->complete = 0;

        if (ngx_event_flags & NGX_USE_IOCP_EVENT) {
            sent = wev->available;

        }
        else {
            if (WSAGetOverlappedResult(c->fd, (LPWSAOVERLAPPED)&wev->evovlp,
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

        /* free sent memory */
        chain = ngx_chain_update_sent(c->out_pending, sent);

        for (cl = c->out_pending; cl && cl != chain; /* void */) {
            ln = cl;
            cl = cl->next;
            ngx_free_chain(c->pool, ln);
        }

        c->out_pending = chain;
    }

    if (0 == size) {
        return NGX_OK;
    }

    /*
    * WSABUFs must be 4-byte aligned otherwise
    * WSASend() will return undocumented WSAEINVAL error.
    */

    vec.elts = wsabufs;
    vec.nelts = 0;
    vec.size = sizeof(WSABUF);
    vec.nalloc = NGX_WSABUFS;
    vec.pool = c->pool;

    wsabuf = NULL;

    /* try append the in data to the tail of the existent chain(c->out_pending),
    and post the overlapped WSASend() */
    tail = &c->out_pending;
    while ((*tail) != NULL) {
        tail = &(*tail)->next;
    }

	remain = size;

    /* create the WSABUF and coalesce the neighbouring bufs */
    while (vec.nelts < ngx_max_wsabufs && remain > 0)
    {
        if ((*tail) == NULL) {
            /* alloc new chunk, and fill chunk data */
            drain = ngx_min(remain, NGX_WSABUF_SIZE_MAX);

            ln = ngx_alloc_chain_link(c->pool);
            if (ln == NULL) {
                return NGX_ERROR;
            }

            ln->buf = ngx_create_temp_buf(c->pool, NGX_WSABUF_SIZE_MAX);
            ngx_copy(ln->buf->last, buf + (size - remain), drain);
            ln->buf->last += drain;
            ln->next = NULL;

            (*tail) = ln;

            wsabuf = ngx_array_push(&vec);
            if (wsabuf == NULL) {
                return NGX_ERROR;
            }

            wsabuf->buf = (char *)(*tail)->buf->pos;
            wsabuf->len = drain;

        }
        else {

			drain = ngx_min(remain, (u_long)((*tail)->buf->end - (*tail)->buf->last));

            if (drain > 0) {
                /* fill chunk data */
                ngx_copy((*tail)->buf->last, buf + (size - remain), drain);
                (*tail)->buf->last += drain;

                wsabuf->len += drain;
            }
            else {
                /* chunk is full */
                tail = &(*tail)->next;
                continue;
            }
        }

        /* drain buf */
		remain -= drain;
    }

    ovlp = (LPWSAOVERLAPPED) &c->write->evovlp;
    ngx_memzero(ovlp, sizeof(WSAOVERLAPPED));

	sent = 0;
    rc = WSASend(c->fd, vec.elts, vec.nelts, &sent, 0, ovlp, NULL);

    ngx_log_debug4(NGX_LOG_DEBUG_EVENT, c->log, 0,
                    "WSASend: fd:%d, %d, %ul of %uz", c->fd, rc, sent, size);

#if (NGX_DEBUG)
    // debug
	output_debug_string("\nngx_overlapped_wsasend(): post event WSASend() of sent(%ld)nelts(%d) on -- c(%d)fd(%d)destroyed(%d)_r(0x%08x)w(0x%08x)c(0x%08x) ... w(%d)\n",
        sent, vec.nelts,
        c->id, c->fd, c->destroyed, (uintptr_t)c->read, (uintptr_t)c->write, (uintptr_t)c, wev->write);

	if (sent > 65535 || size != sent) {
		output_debug_string("error of size(%ld)/sent(%ld) -- fd(%d)!!!!\n",
			size, sent, c->fd);
	}

#endif

    if (rc == 0) {
  
        if (size != sent) {
            wev->error = 1;
            return NGX_ERROR;
        }

        c->sent += sent;

        if (ngx_event_flags & NGX_USE_IOCP_EVENT) {
            wev->active = 1;
        }

        return sent;
    }
    else {

        err = ngx_socket_errno;

        if (err == WSA_IO_PENDING) {
			ngx_log_debug0(NGX_LOG_DEBUG_EVENT, c->log, err,
				"WSASend() posted");
			wev->active = 1;
			return NGX_AGAIN;
        }

#if (NGX_DEBUG)
		// debug
		output_debug_string("\nngx_overlapped_wsasend(): errno=(%llu)!!!!\n",
			(uint64_t)err);
#endif
    }

    wev->error = 1;
    ngx_connection_error(c, err, "WSASend() failed");

    return NGX_ERROR;
}
