
static void ngx_http_wait_request_handlerex(ngx_event_t *ev);
static void ngx_http_keepalive_handlerex(ngx_event_t *ev);
static void ngx_http_lingering_close_handlerex(ngx_event_t *rev);

#if (NGX_HTTP_SSL)
static void ngx_http_ssl_handshakeex(ngx_event_t *rev);
static void ngx_http_ssl_handshakeex2(ngx_event_t *rev);
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
    ngx_http_core_srv_conf_t  *cscf;

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

        }
        else if (b->start == NULL) {

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

        b->pos = p;

        if (b->pos == b->last) {
            c->log->action = "waiting for request";
            b->pos = b->start;
            b->last = b->start;
            ngx_post_event(rev, &ngx_posted_events);
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


static void
ngx_http_keepalive_handlerex(ngx_event_t *rev)
{
    size_t             size;
    ssize_t            n;
    ngx_buf_t         *b;
    ngx_connection_t  *c;

    c = rev->data;

    ngx_log_debug0(NGX_LOG_DEBUG_HTTP, c->log, 0, "http keepalive handler");

    if (rev->timedout || c->close) {
        ngx_http_close_connection(c);
        return;
    }

#if (NGX_HAVE_KQUEUE)

    if (ngx_event_flags & NGX_USE_KQUEUE_EVENT) {
        if (rev->pending_eof) {
            c->log->handler = NULL;
            ngx_log_error(NGX_LOG_INFO, c->log, rev->kq_errno,
                          "kevent() reported that client %V closed "
                          "keepalive connection", &c->addr_text);
#if (NGX_HTTP_SSL)
            if (c->ssl) {
                c->ssl->no_send_shutdown = 1;
            }
#endif
            ngx_http_close_connection(c);
            return;
        }
    }

#endif

    b = c->buffer;
    size = b->end - b->start;

    if (b->pos == NULL) {

        /*
        * The c->buffer's memory was freed by ngx_http_set_keepalive().
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

#if (NGX_DEBUG)
	// debug
	output_debug_string("\nngx_http_keepalive_handlerex(): c(%d)fd(%d)destroyed(%d)_r(0x%08x)w(0x%08x)c(0x%08x) ... sockaddr(0x%08x)sa_family(%d).\n",
		c->id, c->fd, c->destroyed, (uintptr_t)c->read, (uintptr_t)c->write, (uintptr_t)c,
		(uintptr_t)c->sockaddr, c->sockaddr->sa_family);
#endif

    c->sent = 0;
    c->destroyed = 0;

    ngx_del_timer(rev);

    rev->handler = ngx_http_process_request_line;
    ngx_http_process_request_line(rev);
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
    }
    else if (b->start == NULL) {

        b->start = ngx_palloc(c->pool, size);
        if (b->start == NULL) {
            ngx_http_close_connection(c);
            return;
        }

        b->pos = b->start;
        b->last = b->start;
        b->end = b->last + size;
    }
    else if (b->pos == NULL) {

        /*
        * The c->buffer's memory was freed by ngx_http_set_keepalive().
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

    /* loop to drop client data */
    size = b->end - b->start;
    do {
        n = c->recv(c, b->start, size);

        ngx_log_debug1(NGX_LOG_DEBUG_HTTP, c->log, 0, "lingering read: %z", n);

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

		}
		else if (b->start == NULL) {

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

		b->pos = p;

		c->log->action = "SSL handshaking";

		/* data is not enough */
		if (b->pos == b->last) {
			b->pos = b->start;
			b->last = b->start;
			ngx_post_event(rev, &ngx_posted_events);
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

				c->ssl->handler = ngx_http_ssl_handshake_handler;
				return;
			}
		}
		
		ngx_http_ssl_handshake_handler(c);
		return;
	}

	ngx_log_debug0(NGX_LOG_DEBUG_HTTP, rev->log, 0, "plain http");

	c->log->action = "waiting for request";

	rev->handler = ngx_http_wait_request_handlerex;
	ngx_http_wait_request_handlerex(rev);

	return;
}

#endif