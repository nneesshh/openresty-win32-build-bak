
/*
 * Copyright (C) Igor Sysoev
 * Copyright (C) Nginx, Inc.
 */


#include <ngx_config.h>
#include <ngx_core.h>
#include <ngx_event.h>


#define NGX_WSABUF_SIZE_MAX  4096
#define NGX_WSABUFS          16


ngx_chain_t *
ngx_wsasend_chain(ngx_connection_t *c, ngx_chain_t *in, off_t limit)
{
    int           rc;
    u_char       *prev;
    u_long        size, sent, send, prev_send;
    ngx_err_t     err;
    ngx_event_t  *wev;
    ngx_array_t   vec;
    ngx_chain_t  *cl;
    LPWSABUF      wsabuf;
    WSABUF        wsabufs[NGX_WSABUFS];

    /* the maximum limit size is the maximum u_long value - the page size */

    if (limit == 0 || limit > (off_t) (NGX_MAX_UINT32_VALUE - ngx_pagesize)) {
        limit = NGX_MAX_UINT32_VALUE - ngx_pagesize;
    }

    send = 0;

    /*
     * WSABUFs must be 4-byte aligned otherwise
     * WSASend() will return undocumented WSAEINVAL error.
     */

    vec.elts = wsabufs;
    vec.size = sizeof(WSABUF);
    vec.nalloc = NGX_WSABUFS;
    vec.pool = c->pool;

    for ( ;; ) {
        prev = NULL;
        wsabuf = NULL;
        prev_send = send;

        vec.nelts = 0;

        /* create the WSABUF and coalesce the neighbouring bufs */

        for (cl = in;
             cl && vec.nelts < ngx_max_wsabufs && send < (u_long)limit;
             cl = cl->next)
        {
            if (ngx_buf_special(cl->buf)) {
                continue;
            }

            size = cl->buf->last - cl->buf->pos;

            if (send + size > (u_long)limit) {
                size = (u_long) (limit - send);
            }

            if (prev == cl->buf->pos) {
                wsabuf->len += cl->buf->last - cl->buf->pos;

            } else {
                wsabuf = ngx_array_push(&vec);
                if (wsabuf == NULL) {
                    return NGX_CHAIN_ERROR;
                }

                wsabuf->buf = (char *) cl->buf->pos;
                wsabuf->len = cl->buf->last - cl->buf->pos;
            }

            prev = cl->buf->last;
            send += size;
        }

        sent = 0;

        rc = WSASend(c->fd, vec.elts, vec.nelts, &sent, 0, NULL, NULL);

        wev = c->write;

        if (rc == -1) {
            err = ngx_errno;

            if (err == WSAEWOULDBLOCK) {
                ngx_log_debug0(NGX_LOG_DEBUG_EVENT, c->log, err,
                               "WSASend() not ready");

            } else {
                wev->error = 1;
                ngx_connection_error(c, err, "WSASend() failed");
                return NGX_CHAIN_ERROR;
            }
        }

        ngx_log_debug2(NGX_LOG_DEBUG_EVENT, c->log, 0,
                       "WSASend: fd:%d, s:%ul", c->fd, sent);

        c->sent += sent;

        in = ngx_chain_update_sent(in, sent);

        if (send - prev_send != sent) {
            wev->ready = 0;
            return in;
        }

        if (send >= (u_long)limit || in == NULL) {
            return in;
        }
    }
}


ngx_chain_t *
ngx_overlapped_wsasend_chain(ngx_connection_t *c, ngx_chain_t *in, off_t limit)
{
    int               rc;
    u_long            size, bsize, send, sent;
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

                return NGX_CHAIN_ERROR;
            }
        }

        ngx_log_debug2(NGX_LOG_DEBUG_EVENT, c->log, 0,
            "WSAGetOverlappedResult: fd:%d, %ul",
            c->fd, sent);

        /* free sent memory */
        chain = ngx_chain_update_sent(c->out_pending, sent);

        for (cl = c->out_pending; cl && cl != chain; /* void */) {
            ln = cl;
            cl = cl->next;
            ngx_free_chain(c->pool, ln);
        }

        c->out_pending = chain;
    }

    /* the maximum limit size is the maximum u_long value - the page size */
    if (limit == 0 || limit > (off_t) (NGX_MAX_UINT32_VALUE - ngx_pagesize))
    {
        limit = NGX_MAX_UINT32_VALUE - ngx_pagesize;
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

    send = 0;
    wsabuf = NULL;

    /* try append the in data to the tail of the existent chain(c->out_pending),
    and post the overlapped WSASend() */
    tail = &c->out_pending;
    while ((*tail) != NULL) {
        tail = &(*tail)->next;
    }

    /* create the WSABUF and coalesce the neighbouring bufs */
    cl = in;
    while(cl && vec.nelts < NGX_WSABUFS && send < (u_long)limit)
    {
        if (ngx_buf_special(cl->buf)) {
            continue;
        }

        bsize = ngx_buf_size(cl->buf);

        if (0 == bsize) {
            /* cl->buf is empty */
            cl = cl->next;
            continue;
        }

        size = ngx_min(bsize, (u_long)(limit - send));

        if ((*tail) == NULL) {
            /* alloc new chunk, and fill chunk data */
            size = ngx_min(size, NGX_WSABUF_SIZE_MAX);

            ln = ngx_alloc_chain_link(c->pool);
            if (ln == NULL) {
                return NGX_CHAIN_ERROR;
            }

            ln->buf = ngx_create_temp_buf(c->pool, NGX_WSABUF_SIZE_MAX);
            ngx_copy(ln->buf->last, cl->buf->pos, size);
            ln->buf->last += size;
            ln->next = NULL;

            (*tail) = ln;

            wsabuf = ngx_array_push(&vec);
            if (wsabuf == NULL) {
                return NGX_CHAIN_ERROR;
            }

            wsabuf->buf = (char *)(*tail)->buf->pos;
            wsabuf->len = size;

        }
        else {

            size = ngx_min(size, (u_long)((*tail)->buf->end - (*tail)->buf->last));

            if (size > 0) {
                /* fill chunk data */
                ngx_copy((*tail)->buf->last, cl->buf->pos, size);
                (*tail)->buf->last += size;

                wsabuf->len += size;
            }
            else {
                /* chunk is full */
                tail = &(*tail)->next;
                continue;
            }
        }

        send += size;

        /* drain cl buf */
        if (ngx_buf_in_memory(cl->buf)) {
            cl->buf->pos += size;
        }

        if (cl->buf->in_file) {
            cl->buf->file_pos += size;
        }

        if (size == bsize) {
            /* cl->buf is empty */
            cl = cl->next;
        }
    }

    ovlp = (LPWSAOVERLAPPED) &c->write->evovlp;
    ngx_memzero(ovlp, sizeof(WSAOVERLAPPED));

	sent = 0;
    rc = WSASend(c->fd, vec.elts, vec.nelts, &sent, 0, ovlp, NULL);

#if (NGX_DEBUG)
    // debug
	output_debug_string("\nngx_overlapped_wsasend_chain(): post event WSASend() of sent(%ld)nelts(%d) on -- c(%d)fd(%d)destroyed(%d)_r(0x%08x)w(0x%08x)c(0x%08x) ... w(%d)\n",
        sent, vec.nelts,
        c->id, c->fd, c->destroyed, (uintptr_t)c->read, (uintptr_t)c->write, (uintptr_t)c, wev->write);

	if (sent > 65535 || send != sent) {
		output_debug_string("error of send(%ld)/sent(%ld) -- fd(%d)!!!!\n",
			send, sent, c->fd);
	}

#endif

    if (rc == 0) {
        c->sent += sent;

        if (ngx_event_flags & NGX_USE_IOCP_EVENT) {
            wev->active = 1;
        }

        return cl;
    }
    else {

        err = ngx_errno;

        if (err == WSA_IO_PENDING) {
            ngx_log_debug0(NGX_LOG_DEBUG_EVENT, c->log, err,
                "WSASend() posted");

            c->sent += sent;

            wev->active = 1;

            return cl;
        }

#if (NGX_DEBUG)
		// debug
		output_debug_string("\nngx_overlapped_wsasend_chain(): errno=(%llu)!!!!\n",
			(uint64_t)err);
#endif
    }
     
    wev->error = 1;
    ngx_connection_error(c, err, "WSASend() failed");
    return NGX_CHAIN_ERROR;
}
