
static void ngx_http_wait_request_handlerex(ngx_event_t *ev);
static ssize_t ngx_http_read_request_headerex(ngx_http_request_t *r);
static void ngx_http_set_keepaliveex(ngx_http_request_t *r);
static void ngx_http_keepalive_handlerex(ngx_event_t *ev);
static void ngx_http_lingering_close_handlerex(ngx_event_t *rev);

#if (NGX_HTTP_SSL)
static void ngx_http_ssl_handshakeex(ngx_event_t *rev);
static void ngx_http_ssl_handshakeex2(ngx_event_t *rev);
static void ngx_http_ssl_handshake_handlerex(ngx_connection_t *c);
#endif


static void
ngx_http_wait_request_handlerex(ngx_event_t *rev)
{
    u_char                    *p;
    size_t                     size;
    ssize_t                    n;
    ngx_buf_t                 *b;
    ngx_connection_t          *c;
    ngx_http_connection_t     *hc;
    ngx_http_core_srv_conf_t  *cscf = NULL;

    c = rev->data;

    ngx_log_debug0(NGX_LOG_DEBUG_HTTP, c->log, 0, "http wait request handler");

    if (rev->timedout) {
        ngx_log_error(NGX_LOG_INFO, c->log, NGX_ETIMEDOUT, "client timed out");
        ngx_http_close_connection(c);
        return;
    }

    if (c->close) {
        ngx_http_close_connection(c);
        return;
    }

    hc = c->data;
    cscf = ngx_http_get_module_srv_conf(hc->conf_ctx, ngx_http_core_module);

    size = cscf->client_header_buffer_size;

    b = c->buffer;

    if (b != NULL && b->pos < b->last) {
        /* data read by ngx_acceptex() */
        n = (b->last - b->pos);
    }
    else {
        /* recv */
        if (b == NULL) {
            b = ngx_create_temp_buf(c->pool, size);
            if (b == NULL) {
                ngx_http_close_connection(c);
                return;
            }

            c->buffer = b;

        } else if (b->start == NULL) {

            b->start = ngx_palloc(c->pool, size);
            if (b->start == NULL) {
                ngx_http_close_connection(c);
                return;
            }

            b->pos = b->start;
            b->last = b->start;
            b->end = b->last + size;
        }

        /* MUST check buffer size here because maybe "b->last != b->start" */
        if ((b->end - b->last) < (int)size
            && c->read->ready == 1) {
            b->last = b->pos = b->start;
        }

        size = (b->end - b->last);
        n = c->recv(c, b->last, size);

        if (n == NGX_AGAIN) {

            if (!rev->timer_set) {
                ngx_add_timer(rev, c->listening->post_accept_timeout);
                ngx_reusable_connection(c, 1);
            }

            /*
             * MUST post an IOCP read event again because the previous "c->recv" maybe return NGX_AGAIN
             *  from SSL_read, and it means ssl need more data to decrypt the request.
             */
            if (c->read->ready) {
                if (ngx_recv(c, b->last, size) == NGX_ERROR) {
                    ngx_http_close_connection(c);
                    return;
                }
            }

            /* NOTICE: we are just post an IOCP read event, so MUST NOT free c->buffer */

            /* MUST COMMENT THE FOLLOWING LINE
            if (ngx_handle_read_event(rev, 0) != NGX_OK) {
                ngx_http_close_connection(c);
                return;
            }
            */
            /*
             * We are trying to not hold c->buffer's memory for an idle connection.
             */
            /* MUST COMMENT THE FOLLOWING LINE
            if (ngx_pfree(c->pool, b->start) == NGX_OK) {
                b->start = NULL;
            }*/

            return;
        }

        if (n == NGX_ERROR) {
            ngx_http_close_connection(c);
            return;
        }

        if (n == 0) {
            ngx_log_error(NGX_LOG_INFO, c->log, 0,
                "client closed connection");
            ngx_http_close_connection(c);
            return;
        }

        /* data completed by ngx_overlapped_wsarecv() */
        b->last += n;
    }
    
    if (hc->proxy_protocol) {
        hc->proxy_protocol = 0;

        p = ngx_proxy_protocol_read(c, b->pos, b->last);

        if (p == NULL) {
            ngx_http_close_connection(c);
            return;
        }

        /* skip proxy protocol */
        b->pos = p;

        c->log->action = "waiting for request";

        if (b->pos == b->last) {
            /*
             * MUST post an IOCP read event again because we need more data for proxy protocol skipping.
             */
            if (c->read->ready) {
                if (ngx_recv(c, b->last, size) == NGX_ERROR) {
                    ngx_http_close_connection(c);
                    return;
                }
            }
            return;
        }
    }

    c->log->action = "reading client request line";

    ngx_reusable_connection(c, 0);

    c->data = ngx_http_create_request(c);
    if (c->data == NULL) {
        ngx_http_close_connection(c);
        return;
    }

    rev->handler = ngx_http_process_request_line;
    ngx_http_process_request_line(rev);
}


static ssize_t
ngx_http_read_request_headerex(ngx_http_request_t *r)
{
    ssize_t                    n;
    ngx_event_t               *rev;
    ngx_connection_t          *c;
    ngx_http_core_srv_conf_t  *cscf;

    c = r->connection;
    rev = c->read;

    n = r->header_in->last - r->header_in->pos;

    if (n > 0) {
        return n;
    }

    if (rev->ready) {
        n = c->recv(c, r->header_in->last,
                    r->header_in->end - r->header_in->last);
    } else {
        n = NGX_AGAIN;
    }

    if (n == NGX_AGAIN) {
        if (!rev->timer_set) {
            cscf = ngx_http_get_module_srv_conf(r, ngx_http_core_module);
            ngx_add_timer(rev, cscf->client_header_timeout);
        }

        /*
         * MUST post an IOCP read event again because the previous "c->recv" maybe return NGX_AGAIN
         *  from SSL_read, and it means ssl need more data to decrypt the request.
         */
        if (c->read->ready) {
            if (ngx_recv(c, r->header_in->last,
                r->header_in->end - r->header_in->last) == NGX_ERROR) {
                ngx_http_close_request(r, NGX_HTTP_INTERNAL_SERVER_ERROR);
                return NGX_ERROR;
            }
        }

        /* MUST COMMENT THE FOLLOWING LINE
        if (ngx_handle_read_event(rev, 0) != NGX_OK) {
            ngx_http_close_request(r, NGX_HTTP_INTERNAL_SERVER_ERROR);
            return NGX_ERROR;
        } */

        return NGX_AGAIN;
    }

    if (n == 0) {
        ngx_log_error(NGX_LOG_INFO, c->log, 0,
                      "client prematurely closed connection");
    }

    if (n == 0 || n == NGX_ERROR) {
        c->error = 1;
        c->log->action = "reading client request headers";

        ngx_http_finalize_request(r, NGX_HTTP_BAD_REQUEST);
        return NGX_ERROR;
    }

    r->header_in->last += n;

    return n;
}


static void
ngx_http_set_keepaliveex(ngx_http_request_t *r)
{
    int                        tcp_nodelay;
    ngx_buf_t                 *b, *f;
    ngx_chain_t               *cl, *ln;
    ngx_event_t               *rev, *wev;
    ngx_connection_t          *c;
    ngx_http_connection_t     *hc;
    ngx_http_core_loc_conf_t  *clcf;

    c = r->connection;
    rev = c->read;

    clcf = ngx_http_get_module_loc_conf(r, ngx_http_core_module);

    ngx_log_debug0(NGX_LOG_DEBUG_HTTP, c->log, 0, "set http keepalive handler");

    if (r->discard_body) {
        r->write_event_handler = ngx_http_request_empty_handler;
        r->lingering_time = ngx_time() + (time_t) (clcf->lingering_time / 1000);
        ngx_add_timer(rev, clcf->lingering_timeout);
        return;
    }

    c->log->action = "closing request";

    hc = r->http_connection;
    b = r->header_in;

    if (b->pos < b->last) {

        /* the pipelined request */

        if (b != c->buffer) {

            /*
             * If the large header buffers were allocated while the previous
             * request processing then we do not use c->buffer for
             * the pipelined request (see ngx_http_create_request()).
             *
             * Now we would move the large header buffers to the free list.
             */

            for (cl = hc->busy; cl; /* void */) {
                ln = cl;
                cl = cl->next;

                if (ln->buf == b) {
                    ngx_free_chain(c->pool, ln);
                    continue;
                }

                f = ln->buf;
                f->pos = f->start;
                f->last = f->start;

                ln->next = hc->free;
                hc->free = ln;
            }

            cl = ngx_alloc_chain_link(c->pool);
            if (cl == NULL) {
                ngx_http_close_request(r, 0);
                return;
            }

            cl->buf = b;
            cl->next = NULL;

            hc->busy = cl;
            hc->nbusy = 1;
        }
    }

    /* guard against recursive call from ngx_http_finalize_connection() */
    r->keepalive = 0;

    ngx_http_free_request(r, 0);

    c->data = hc;

    wev = c->write;
    wev->handler = ngx_http_empty_handler;

    if (b->pos < b->last) {

        ngx_log_debug0(NGX_LOG_DEBUG_HTTP, c->log, 0, "pipelined request");

        c->log->action = "reading client pipelined request line";

        r = ngx_http_create_request(c);
        if (r == NULL) {
            ngx_http_close_connection(c);
            return;
        }

        r->pipeline = 1;

        c->data = r;

        c->sent = 0;
        c->destroyed = 0;

        if (rev->timer_set) {
            ngx_del_timer(rev);
        }

        rev->handler = ngx_http_process_request_line;
        ngx_post_event(rev, &ngx_posted_events);
        return;
    }

#if (NGX_DEBUG)
    // debug
    output_debug_string(c->log, "\nngx_http_set_keepaliveex(): c(%d)fd(%d)destroyed(%d)_r(0x%08x)w(0x%08x)c(0x%08x) ... sockaddr(0x%08x)sa_family(%d).\n",
        c->id, c->fd, c->destroyed, (uintptr_t)c->read, (uintptr_t)c->write, (uintptr_t)c,
        (uintptr_t)c->sockaddr, c->sockaddr->sa_family);
#endif

    /*
     * To keep a memory footprint as small as possible for an idle keepalive
     * connection: we keeps the IOCP event buffer(the c->buffer or r->header_in)'s memory
     * , and frees the large header buffers that are always allocated outside the c->pool.
     */

    b = c->buffer;

    if (ngx_pfree(c->pool, b->start) == NGX_OK) {

        /*
         * the special note for ngx_http_keepalive_handler() that
         * c->buffer's memory was freed
         */

        b->pos = NULL;

    } else {
        b->pos = b->start;
        b->last = b->start;
    }

    /*
     * NOTICE: we must reborn the c->buffer at here becasue SSL_read maybe not complete yet, and
     *          we MUST reset buf to ensure enough space to contain output data from SSL_read.
     */
    if (b->pos == NULL) {

        /*
         * The c->buffer's memory was freed by ngx_http_set_keepaliveex().
         * However, the c->buffer->start and c->buffer->end were not changed
         * to keep the buffer size.
         */

#define NGX_KEEPALIVE_REBORN_BUFFER_SIZE  4096

        b->pos = ngx_palloc(c->pool, NGX_KEEPALIVE_REBORN_BUFFER_SIZE);
        if (b->pos == NULL) {
            ngx_http_close_connection(c);
            return;
        }

        b->start = b->pos;
        b->last = b->pos;
        b->end = b->pos + NGX_KEEPALIVE_REBORN_BUFFER_SIZE;
    }

    /*
     * MUST post an IOCP read event again because rev->ready maybe 1
     */
    if (rev->ready) {
        if (ngx_recv(c, b->last, b->end - b->last) == NGX_ERROR) {
            ngx_http_close_connection(c);
            return;
        }
    }

    ngx_log_debug1(NGX_LOG_DEBUG_HTTP, c->log, 0, "hc free: %p",
                   hc->free);

    if (hc->free) {
        for (cl = hc->free; cl; /* void */) {
            ln = cl;
            cl = cl->next;
            ngx_pfree(c->pool, ln->buf->start);
            ngx_free_chain(c->pool, ln);
        }

        hc->free = NULL;
    }

    ngx_log_debug2(NGX_LOG_DEBUG_HTTP, c->log, 0, "hc busy: %p %i",
                   hc->busy, hc->nbusy);

    if (hc->busy) {
        for (cl = hc->busy; cl; /* void */) {
            ln = cl;
            cl = cl->next;
            ngx_pfree(c->pool, ln->buf->start);
            ngx_free_chain(c->pool, ln);
        }

        hc->busy = NULL;
        hc->nbusy = 0;
    }

#if (NGX_HTTP_SSL)
    if (c->ssl) {
        ngx_ssl_free_buffer(c);
    }
#endif

    rev->handler = ngx_http_keepalive_handlerex;

    c->log->action = "keepalive";

    if (c->tcp_nopush == NGX_TCP_NOPUSH_SET) {
        if (ngx_tcp_push(c->fd) == -1) {
            ngx_connection_error(c, ngx_socket_errno, ngx_tcp_push_n " failed");
            ngx_http_close_connection(c);
            return;
        }

        c->tcp_nopush = NGX_TCP_NOPUSH_UNSET;
        tcp_nodelay = ngx_tcp_nodelay_and_tcp_nopush ? 1 : 0;

    } else {
        tcp_nodelay = 1;
    }

    if (tcp_nodelay && clcf->tcp_nodelay && ngx_tcp_nodelay(c) != NGX_OK) {
        ngx_http_close_connection(c);
        return;
    }

#if 0
    /* if ngx_http_request_t was freed then we need some other place */
    r->http_state = NGX_HTTP_KEEPALIVE_STATE;
#endif

    c->idle = 1;
    ngx_reusable_connection(c, 1);

    ngx_add_timer(rev, clcf->keepalive_timeout);

    /* IOCP read event already posted, no need to post again
    if (rev->ready) {
        ngx_post_event(rev, &ngx_posted_events);
    }*/
}


static void
ngx_http_keepalive_handlerex(ngx_event_t *rev)
{
    size_t             size;
    ssize_t            n;
    ngx_buf_t         *b;
    ngx_connection_t  *c;

    c = rev->data;

#if (NGX_DEBUG)
    // debug
    output_debug_string(c->log, "\nngx_http_keepalive_handlerex(): begin -- c(%d)fd(%d)destroyed(%d)_r(0x%08x)w(0x%08x)c(0x%08x) ... sockaddr(0x%08x)sa_family(%d).\n",
        c->id, c->fd, c->destroyed, (uintptr_t)c->read, (uintptr_t)c->write, (uintptr_t)c,
        (uintptr_t)c->sockaddr, c->sockaddr->sa_family);
#endif

    ngx_log_debug0(NGX_LOG_DEBUG_HTTP, c->log, 0, "http keepalive handler");

    if (rev->timedout || c->close) {
        ngx_http_close_connection(c);
        return;
    }

    b = c->buffer;
    size = b->end - b->start;

    if (b->pos == NULL) {

        /*
         * The c->buffer's memory was freed by ngx_http_set_keepaliveex().
         * However, the c->buffer->start and c->buffer->end were not changed
         * to keep the buffer size.
         */

        b->pos = ngx_palloc(c->pool, size);
        if (b->pos == NULL) {
            ngx_http_close_connection(c);
            return;
        }

        b->start = b->pos;
        b->last = b->pos;
        b->end = b->pos + size;
    }

    size = b->end - b->last;

    /*
     * MSIE closes a keepalive connection with RST flag
     * so we ignore ECONNRESET here.
     */

    c->log_error = NGX_ERROR_IGNORE_ECONNRESET;
    ngx_set_socket_errno(0);

    n = c->recv(c, b->last, size);
    c->log_error = NGX_ERROR_INFO;

    if (n == NGX_AGAIN) {

        /*
         * MUST post an IOCP read event again because the previous "c->recv" maybe return NGX_AGAIN
         *  from SSL_read, and it means ssl need more data to decrypt the request.
         */
        if (c->read->ready) {
            if (ngx_recv(c, b->last, size) == NGX_ERROR) {
                ngx_http_close_connection(c);
                return;
            }
        }

        /* NOTICE: we are just post an IOCP read event, so MUST NOT free c->buffer */

        /* MUST COMMENT THE FOLLOWING LINE
        if (ngx_handle_read_event(rev, 0) != NGX_OK) {
            ngx_http_close_connection(c);
            return;
        }
        */
        /*
         * Like ngx_http_set_keepalive() we are trying to not hold
         * c->buffer's memory for a keepalive connection.
         */
        /* MUST COMMENT THE FOLLOWING LINE
        if (ngx_pfree(c->pool, b->start) == NGX_OK) {
        */
            /*
             * the special note that c->buffer's memory was freed
             */
        /*
            b->pos = NULL;
        }*/

        return;
    }

    if (n == NGX_ERROR) {
        ngx_http_close_connection(c);
        return;
    }

    c->log->handler = NULL;

    if (n == 0) {
        ngx_log_error(NGX_LOG_INFO, c->log, ngx_socket_errno,
                      "client %V closed keepalive connection", &c->addr_text);
        ngx_http_close_connection(c);
        return;
    }

    /* data completed by ngx_overlapped_wsarecv() */
    b->last += n;

    c->log->handler = ngx_http_log_error;
    c->log->action = "reading client request line";

    c->idle = 0;
    ngx_reusable_connection(c, 0);

    c->data = ngx_http_create_request(c);
    if (c->data == NULL) {
        ngx_http_close_connection(c);
        return;
    }

    c->sent = 0;
    c->destroyed = 0;

    ngx_del_timer(rev);

    rev->handler = ngx_http_process_request_line;
    ngx_http_process_request_line(rev);

#if (NGX_DEBUG)
    // debug
    output_debug_string(c->log, "\nngx_http_keepalive_handlerex(): end -- c(%d)fd(%d)destroyed(%d)_r(0x%08x)w(0x%08x)c(0x%08x) ... sockaddr(0x%08x)sa_family(%d).\n",
        c->id, c->fd, c->destroyed, (uintptr_t)c->read, (uintptr_t)c->write, (uintptr_t)c,
        (uintptr_t)c->sockaddr, c->sockaddr->sa_family);
#endif
}


static void
ngx_http_lingering_close_handlerex(ngx_event_t *rev)
{
    ssize_t                    n;
    ngx_msec_t                 timer;
    ngx_connection_t          *c;
    ngx_http_request_t        *r;
    ngx_http_core_loc_conf_t  *clcf;

    size_t                     size;
    ngx_buf_t                 *b;

    c = rev->data;
    r = c->data;

    ngx_log_debug0(NGX_LOG_DEBUG_HTTP, c->log, 0,
        "http lingering close handler");

    if (rev->timedout) {
        ngx_http_close_request(r, 0);
        return;
    }

    timer = (ngx_msec_t)r->lingering_time - (ngx_msec_t)ngx_time();
    if ((ngx_msec_int_t)timer <= 0) {
        ngx_http_close_request(r, 0);
        return;
    }

    b = c->buffer;
    size = NGX_HTTP_LINGERING_BUFFER_SIZE;

    if (b == NULL) {

        b = ngx_create_temp_buf(c->pool, size);
        if (b == NULL) {
            ngx_http_close_request(r, 0);
            return;
        }

        c->buffer = b;

    } else if (b->start == NULL) {

        b->start = ngx_palloc(c->pool, size);
        if (b->start == NULL) {
            ngx_http_close_connection(c);
            return;
        }

        b->pos = b->start;
        b->last = b->start;
        b->end = b->last + size;

    } else if (b->pos == NULL) {

        /*
         * The c->buffer's memory was freed by ngx_http_set_keepaliveex().
         * However, the c->buffer->start and c->buffer->end were not changed
         * to keep the buffer size.
         */

        b->pos = ngx_palloc(c->pool, size);
        if (b->pos == NULL) {
            ngx_http_close_connection(c);
            return;
        }

        b->start = b->pos;
        b->last = b->pos;
        b->end = b->pos + size;
    }

    /* loop to drop client data in buffer */
    size = b->end - b->last;
    do {
        n = ngx_recv(c, b->last, size);

        ngx_log_debug1(NGX_LOG_DEBUG_HTTP, c->log, 0, "lingering read: %z", n);

        if (n == NGX_AGAIN) {
            break;
        }

        if (n == NGX_ERROR || n == 0) {
            ngx_http_close_request(r, 0);
            return;
        }

    } while (rev->ready);

    clcf = ngx_http_get_module_loc_conf(r, ngx_http_core_module);

    timer *= 1000;

    if (timer > clcf->lingering_timeout) {
        timer = clcf->lingering_timeout;
    }

    ngx_add_timer(rev, timer);
}


#if (NGX_HTTP_SSL)

static void
ngx_http_ssl_handshakeex(ngx_event_t *rev)
{
    u_char                    *p;
    ssize_t                    n, size;
    ngx_buf_t                 *b;
    ngx_connection_t          *c;
    ngx_http_connection_t     *hc;
    ngx_http_ssl_srv_conf_t   *sscf;
    ngx_http_core_loc_conf_t  *clcf;

    int                        ssl_remain;

    c = rev->data;
    hc = c->data;

    ngx_log_debug0(NGX_LOG_DEBUG_HTTP, rev->log, 0,
        "http check ssl handshake");

    if (rev->timedout) {
        ngx_log_error(NGX_LOG_INFO, c->log, NGX_ETIMEDOUT, "client timed out");
        ngx_http_close_connection(c);
        return;
    }

    if (c->close) {
        ngx_http_close_connection(c);
        return;
    }

    b = c->buffer;

    if (b != NULL && b->pos < b->last) {
        /* data read by ngx_acceptex() */
        n = (b->last - b->pos);
    }
    else {
        size = NGX_PROXY_PROTOCOL_MAX_HEADER + 1;

        /* recv */
        if (b == NULL) {
            b = ngx_create_temp_buf(c->pool, size);
            if (b == NULL) {
                ngx_http_close_connection(c);
                return;
            }

            c->buffer = b;

        } else if (b->start == NULL) {

            b->start = ngx_palloc(c->pool, size);
            if (b->start == NULL) {
                ngx_http_close_connection(c);
                return;
            }

            b->pos = b->start;
            b->last = b->start;
            b->end = b->last + size;
        }

        n = c->recv(c, b->last, size);

        ngx_log_debug1(NGX_LOG_DEBUG_HTTP, rev->log, 0, "http recv(): %z", n);

        if (n == NGX_AGAIN) {

            if (!rev->timer_set) {
                ngx_add_timer(rev, c->listening->post_accept_timeout);
                ngx_reusable_connection(c, 1);
            }

            return;
        }

        if (n == NGX_ERROR) {
            ngx_http_close_connection(c);
            return;
        }

        if (n == 0) {
            ngx_log_error(NGX_LOG_INFO, c->log, ngx_socket_errno,
                "client %V closed ssl handshakeex connection", &c->addr_text);
            ngx_http_close_connection(c);
            return;
        }

        /* data completed by ngx_overlapped_wsarecv() */
        b->last += n;
    }

    if (hc->proxy_protocol) {
        hc->proxy_protocol = 0;

        p = ngx_proxy_protocol_read(c, b->pos, b->last);

        if (p == NULL) {
            ngx_http_close_connection(c);
            return;
        }

        /* skip proxy protocol */
        b->pos = p;

        c->log->action = "SSL handshaking";

        if (b->pos == b->last) {
            /*
             * MUST post an IOCP read event again because no more data after skipping proxy protocol.
             */
            if (c->read->ready) {
                if (ngx_recv(c, b->last, size) == NGX_ERROR) {
                    ngx_http_close_connection(c);
                    return;
                }
            }
            return;
        }

        /* */
        n = (b->last - b->pos);
    }

    if (n >= 1) {
        if (b->pos[0] & 0x80 /* SSLv2 */ || b->pos[0] == 0x16 /* SSLv3/TLSv1 */) {
            ngx_log_debug1(NGX_LOG_DEBUG_HTTP, rev->log, 0,
                "https ssl handshake: 0x%02Xd", b->pos[0]);

            clcf = ngx_http_get_module_loc_conf(hc->conf_ctx,
                ngx_http_core_module);

            if (clcf->tcp_nodelay && ngx_tcp_nodelay(c) != NGX_OK) {
                ngx_http_close_connection(c);
                return;
            }

            sscf = ngx_http_get_module_srv_conf(hc->conf_ctx,
                ngx_http_ssl_module);

            if (ngx_ssl_create_connectionex(&sscf->ssl, c, NGX_SSL_BUFFER)
                != NGX_OK)
            {
                ngx_http_close_connection(c);
                return;
            }

            rev->handler = ngx_http_ssl_handshakeex2;

            ssl_remain = b->last - b->pos;

            if (ssl_remain > 0) {
                rev->handler(rev);
            }

            return;
        }

        ngx_log_debug0(NGX_LOG_DEBUG_HTTP, rev->log, 0, "plain http");

        c->log->action = "waiting for request";

        rev->handler = ngx_http_wait_request_handlerex;
        ngx_http_wait_request_handlerex(rev);

        return;
    }

    ngx_log_error(NGX_LOG_INFO, c->log, 0, "client closed connection");
    ngx_http_close_connection(c);
}

static void
ngx_http_ssl_handshakeex2(ngx_event_t *rev)
{
    ssize_t                    n, size;
    ngx_buf_t                 *b;
    ngx_int_t                  rc;
    ngx_connection_t          *c;
    ngx_http_connection_t     *hc;

    c = rev->data;
    hc = c->data;

    ngx_log_debug0(NGX_LOG_DEBUG_HTTP, rev->log, 0,
        "http check ssl handshake");

    if (rev->timedout) {
        ngx_log_error(NGX_LOG_INFO, c->log, NGX_ETIMEDOUT, "client timed out");
        ngx_http_close_connection(c);
        return;
    }

    if (c->close) {
        ngx_http_close_connection(c);
        return;
    }

    b = c->buffer;

    if (b != NULL && b->pos < b->last) {
        /* data read by ngx_acceptex() */
        n = (b->last - b->pos);
    }
    else {
        size = b->end - b->last;

        n = c->recv(c, b->last, size);

        ngx_log_debug1(NGX_LOG_DEBUG_HTTP, rev->log, 0, "http recv(): %z", n);

        if (n == NGX_AGAIN) {

            if (!rev->timer_set) {
                ngx_add_timer(rev, c->listening->post_accept_timeout);
                ngx_reusable_connection(c, 1);
            }

            return;
        }

        if (n == NGX_ERROR) {
            ngx_http_close_connection(c);
            return;
        }

        if (n == 0) {
            ngx_log_error(NGX_LOG_INFO, c->log, ngx_socket_errno,
                "client %V closed ssl handshakeex connection", &c->addr_text);
            ngx_http_close_connection(c);
            return;
        }

        /* data completed by ngx_overlapped_wsarecv() */
        b->last += n;
    }

    if (n > 0) {

        if (0 == c->ssl->handshaked) {
            rc = ngx_ssl_handshakeex(c);

            if (rc == NGX_AGAIN) {

                if (!rev->timer_set) {
                    ngx_add_timer(rev, c->listening->post_accept_timeout);
                }

                ngx_reusable_connection(c, 0);

                c->ssl->handler = ngx_http_ssl_handshake_handlerex;
                return;
            }
        }
        
        ngx_http_ssl_handshake_handlerex(c);
        return;
    }

    ngx_log_debug0(NGX_LOG_DEBUG_HTTP, rev->log, 0, "plain http");

    c->log->action = "waiting for request";

    rev->handler = ngx_http_wait_request_handlerex;
    ngx_http_wait_request_handlerex(rev);

    return;
}


static void
ngx_http_ssl_handshake_handlerex(ngx_connection_t *c)
{
    if (c->ssl->handshaked) {

        /*
         * The majority of browsers do not send the "close notify" alert.
         * Among them are MSIE, old Mozilla, Netscape 4, Konqueror,
         * and Links.  And what is more, MSIE ignores the server's alert.
         *
         * Opera and recent Mozilla send the alert.
         */

        c->ssl->no_wait_shutdown = 1;

#if (NGX_HTTP_V2                                                              \
     && (defined TLSEXT_TYPE_application_layer_protocol_negotiation           \
         || defined TLSEXT_TYPE_next_proto_neg))
        {
        unsigned int            len;
        const unsigned char    *data;
        ngx_http_connection_t  *hc;

        hc = c->data;

        if (hc->addr_conf->http2) {

#ifdef TLSEXT_TYPE_application_layer_protocol_negotiation
            SSL_get0_alpn_selected(c->ssl->connection, &data, &len);

#ifdef TLSEXT_TYPE_next_proto_neg
            if (len == 0) {
                SSL_get0_next_proto_negotiated(c->ssl->connection, &data, &len);
            }
#endif

#else /* TLSEXT_TYPE_next_proto_neg */
            SSL_get0_next_proto_negotiated(c->ssl->connection, &data, &len);
#endif

            if (len == 2 && data[0] == 'h' && data[1] == '2') {
                ngx_http_v2_init(c->read);
                return;
            }
        }
        }
#endif

        c->log->action = "waiting for request";

        c->read->handler = ngx_http_wait_request_handlerex;
        /* STUB: epoll edge */ c->write->handler = ngx_http_empty_handler;

        ngx_reusable_connection(c, 1);

        ngx_http_wait_request_handlerex(c->read);

        return;
    }

    if (c->read->timedout) {
        ngx_log_error(NGX_LOG_INFO, c->log, NGX_ETIMEDOUT, "client timed out");
    }

    ngx_http_close_connection(c);
}


#endif