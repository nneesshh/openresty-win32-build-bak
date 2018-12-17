
/*
 * Copyright (C) Igor Sysoev
 * Copyright (C) Nginx, Inc.
 */


#include <ngx_config.h>
#include <ngx_core.h>
#include <ngx_event.h>


#define NGX_WSABUF_SIZE_MAX  4096
#define NGX_WSABUFS  8


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

    wev = c->write;

    if (!wev->ready) {
        return in;
    }

    /* the maximum limit size is the maximum long value - the page size */

    if (limit == 0 || limit > (off_t) (NGX_MAX_INT32_VALUE - ngx_pagesize)) {
        limit = NGX_MAX_INT32_VALUE - ngx_pagesize;
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
    u_long            remain, drain, size, send, sent;
    ngx_err_t         err;
    ngx_event_t      *wev;
    ngx_array_t       vec;
    ngx_chain_t      *cl, *ln, **tail, *chain;
    LPWSAOVERLAPPED   ovlp;
    LPWSABUF          wsabuf;
    WSABUF            wsabufs[NGX_WSABUFS];

    wev = c->write;

    if (!wev->ready) {
        return in;
    }

    ngx_log_debug1(NGX_LOG_DEBUG_EVENT, c->log, 0,
                   "wev->complete: %d", wev->complete);

    /* first unlock sent memory if wev->complete=1 */
    if (wev->complete) {
        
        /* the overlapped WSASend() complete */

        wev->complete = 0;
        wev->active = 0;

        if (ngx_event_flags & NGX_USE_IOCP_EVENT) {

            /*if (wev->evovlp.error) {
                ngx_connection_error(c, wev->evovlp.error, "WSASend() failed");
                return NGX_CHAIN_ERROR;
            }*/

            sent = wev->available;

        } else {
            if (WSAGetOverlappedResult(c->fd, (LPWSAOVERLAPPED) &wev->evovlp,
                                       &sent, 0, NULL)
                == 0)
            {
                ngx_connection_error(c, ngx_socket_errno,
                               "WSASend() or WSAGetOverlappedResult() failed");

                return NGX_CHAIN_ERROR;
            }
        }

        ngx_log_debug2(NGX_LOG_DEBUG_EVENT, c->log, 0,
                   "WSASend ovlp: fd:%d, s:%ul", c->fd, sent);

        c->sent += sent;

        /* free sent memory by sent size when wen->complete=0 */
        chain = ngx_chain_update_sent(c->out_pending, sent);

        for (cl = c->out_pending; cl && cl != chain; /* void */) {
            ln = cl;
            cl = cl->next;
            ngx_free_chain(c->pool, ln);
        }

        c->out_pending = chain;
    }

    /* second copy buf into c->out_pending and send */
    {
        
        /* post the overlapped WSASend() */

        /* the maximum limit size is the maximum long value - the page size */

        if (limit == 0 || limit > (off_t) (NGX_MAX_INT32_VALUE - ngx_pagesize))
        {
            limit = NGX_MAX_INT32_VALUE - ngx_pagesize;
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

        while (cl && vec.nelts < ngx_max_wsabufs && send < (u_long)limit) {

            if (ngx_buf_special(cl->buf)) {
                /* cl->buf is special, skip it and continue to process next */
                cl = cl->next;
                continue;
            }

            remain = cl->buf->last - cl->buf->pos;

            while (remain > 0) {
                /* drain data from cl->buf and copy into c->out_pending */
                drain = ngx_min(remain, (u_long)(limit - send));

                if ((*tail) == NULL
                    || (*tail)->buf->end - (*tail)->buf->last == 0) {
                    /* alloc new chunk, and fill chunk data */
                    size = ngx_min(drain, NGX_WSABUF_SIZE_MAX);

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
                    size = ngx_min(drain, (u_long)((*tail)->buf->end - (*tail)->buf->last));

                    /* fill chunk data */
                    ngx_copy((*tail)->buf->last, cl->buf->pos, size);
                    (*tail)->buf->last += size;

                    wsabuf->len += size;
                }

                send += size;

                /* drain cl->buf */
                if (ngx_buf_in_memory(cl->buf)) {
                    cl->buf->pos += size;
                }

                if (cl->buf->in_file) {
                    cl->buf->file_pos += size;
                }

                remain -= size;
            }


            /* cl->buf is empty, continue to process next */
            cl = cl->next;
        }

        ovlp = (LPWSAOVERLAPPED) &c->write->evovlp;
        ngx_memzero(ovlp, sizeof(WSAOVERLAPPED));

        rc = WSASend(c->fd, vec.elts, vec.nelts, &sent, 0, ovlp, NULL);

        wev->complete = 0;

#if (NGX_DEBUG)
        // debug
        output_debug_string(c, "\nngx_overlapped_wsasend_chain(): post event WSASend() of sent(%d)nelts(%d) on -- c(%d)fd(%d)destroyed(%d)_r(0x%08xd)w(0x%08xd)c(0x%08xd) ... w(%d)\n",
            (int)sent, vec.nelts,
            c->id, c->fd, c->destroyed, (uintptr_t)c->read, (uintptr_t)c->write, (uintptr_t)c, wev->write);

        if (sent > 65535 || send != sent) {
            output_debug_string(c, "error of send(%d)/sent(%d) -- fd(%d)!!!!\n",
                (int)send, (int)sent, c->fd);
        }

#endif

        if (rc == -1) {
            err = ngx_errno;

            if (err == WSA_IO_PENDING) {
                ngx_log_debug0(NGX_LOG_DEBUG_EVENT, c->log, err,
                               "WSASend() posted");
                wev->active = 1;
                return cl;

            } else {
#if (NGX_DEBUG)
                // debug
                output_debug_string(c, "\nngx_overlapped_wsasend_chain(): errno=(%llu)!!!!\n",
                    (uint64_t)err);
#endif
                wev->error = 1;
                ngx_connection_error(c, err, "WSASend() failed");
                return NGX_CHAIN_ERROR;
            }

        } else if (ngx_event_flags & NGX_USE_IOCP_EVENT) {

            /*
             * if a socket was bound with I/O completion port then
             * GetQueuedCompletionStatus() would anyway return its status
             * despite that WSASend() was already complete
             */

            wev->active = 1;
            return cl;
        }

        ngx_log_debug2(NGX_LOG_DEBUG_EVENT, c->log, 0,
                       "WSASend: fd:%d, s:%ul", c->fd, sent);

        /* should never reach here */
        wev->error = 1;
        return NGX_CHAIN_ERROR;
    }
}
