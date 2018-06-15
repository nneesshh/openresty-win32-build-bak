
static void ngx_stream_proxy_protocol_handlerex(ngx_event_t *rev);


static void
ngx_stream_proxy_protocol_handlerex(ngx_event_t *rev)
{
    u_char                      *p;
    ssize_t                      n;
    ngx_buf_t                   *b;
    ngx_connection_t            *c;
    ngx_stream_session_t        *s;
    ngx_stream_core_srv_conf_t  *cscf;

    c = rev->data;
    s = c->data;

    ngx_log_debug0(NGX_LOG_DEBUG_STREAM, c->log, 0,
                   "stream PROXY protocol handler");

    if (rev->timedout) {
        ngx_log_error(NGX_LOG_INFO, c->log, NGX_ETIMEDOUT, "client timed out");
        ngx_stream_finalize_session(s, NGX_STREAM_OK);
        return;
    }

    b = c->buffer;

    n = c->recv(c, b->last, NGX_PROXY_PROTOCOL_MAX_HEADER);

    ngx_log_debug1(NGX_LOG_DEBUG_STREAM, c->log, 0, "recv(): %z", n);

    if (n == NGX_EAGAIN) {
        rev->ready = 0;

        if (!rev->timer_set) {
            cscf = ngx_stream_get_module_srv_conf(s,
                ngx_stream_core_module);

            ngx_add_timer(rev, cscf->proxy_protocol_timeout);
        }

        return;
    }

    if (n == NGX_ERROR) {
        ngx_stream_finalize_session(s, NGX_STREAM_OK);
        return;
    }

     /* data completed by ngx_overlapped_wsarecv() */
    b->last += n;

    if (rev->timer_set) {
        ngx_del_timer(rev);
    }

    p = ngx_proxy_protocol_read(c, b->pos, b->last);

    if (p == NULL) {
        ngx_stream_finalize_session(s, NGX_STREAM_BAD_REQUEST);
        return;
    }

    c->log->action = "initializing session";

    ngx_stream_session_handler(rev);
}