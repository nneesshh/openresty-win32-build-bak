
/*
 * Copyright (C) Igor Sysoev
 * Copyright (C) Nginx, Inc.
 */


#include <ngx_config.h>
#include <ngx_core.h>
#include <ngx_event.h>


#if (NGX_DEBUG)
static void ngx_ssl_handshake_logex(ngx_connection_t *c);
#endif
static void ngx_ssl_handshake_handlerex(ngx_event_t *ev);
static ngx_int_t ngx_ssl_handle_recvex(ngx_connection_t *c, int n);
static void ngx_ssl_write_handlerex(ngx_event_t *wev);
static void ngx_ssl_read_handlerex(ngx_event_t *rev);
static void ngx_ssl_shutdown_handlerex(ngx_event_t *ev);
static void ngx_ssl_connection_errorex(ngx_connection_t *c, int sslerr,
    ngx_err_t err, char *text);
static void ngx_ssl_clear_errorex(ngx_log_t *log);


static bool
is_ssl_error(int ssl_error)
{
    switch (ssl_error)
    {
    case SSL_ERROR_NONE:
    case SSL_ERROR_WANT_READ:
    case SSL_ERROR_WANT_WRITE:
    case SSL_ERROR_WANT_CONNECT:
    case SSL_ERROR_WANT_ACCEPT:
        return false;

    default: return true;
    }
}

#define NGX_SSL_POST_IOCP_READ_EVENT_WITH_BUF(c, buf)       \
    do {                                                    \
        size_t     size;                                    \
                                                            \
        if (c->read->ready) {                               \
                                                            \
            if (buf->last == buf->pos && buf->pos != buf->start)  \
                buf->last = buf->pos = buf->start;          \
                                                            \
            size = buf->end - buf->last;                    \
                                                            \
            if (ngx_recv(c, buf->last, size) == NGX_ERROR)  \
                return NGX_ERROR;                           \
                                                            \
            c->read->ready = 0;                             \
        }                                                   \
    } while (0)

#define NGX_SSL_POST_IOCP_READ_EVENT(c) NGX_SSL_POST_IOCP_READ_EVENT_WITH_BUF(c, c->buffer)

static ngx_int_t
ngx_ssl_bio_mem_send(ngx_ssl_connection_t *ssl, ngx_connection_t *c) {

    int          ssl_ret, n;
    size_t       ssl_remain;

    char         *contents;

    ssl_remain = BIO_ctrl_pending(ssl->wbio_mem);
    if (ssl_remain > 0) {

        ssl_ret = BIO_get_mem_data(ssl->wbio_mem, &contents);
        if (ssl_ret != ssl_remain) {
            return NGX_ERROR;
        }

        n = ngx_send(c, (u_char *)contents, ssl_ret);

        if (NGX_ERROR == n
            || (NGX_AGAIN != n && ssl_ret != n)) {
            return NGX_ERROR;
        }

        BIO_reset(ssl->wbio_mem);
    }
    return NGX_OK;
}


ngx_int_t
ngx_ssl_create_connectionex(ngx_ssl_t *ssl, ngx_connection_t *c, ngx_uint_t flags)
{
    ngx_ssl_connection_t  *sc;

    sc = ngx_pcalloc(c->pool, sizeof(ngx_ssl_connection_t));
    if (sc == NULL) {
        return NGX_ERROR;
    }

    sc->buffer = ((flags & NGX_SSL_BUFFER) != 0);
    sc->buffer_size = ssl->buffer_size;

    sc->session_ctx = ssl->ctx;

#ifdef SSL_READ_EARLY_DATA_SUCCESS
    if (SSL_CTX_get_max_early_data(ssl->ctx)) {
        sc->try_early_data = 1;
    }
#endif

    sc->connection = SSL_new(ssl->ctx);

    if (sc->connection == NULL) {
        ngx_ssl_error(NGX_LOG_ALERT, c->log, 0, "SSL_new() failed");
        return NGX_ERROR;
    }

    /*if (SSL_set_fd(sc->connection, c->fd) == 0) {
        ngx_ssl_error(NGX_LOG_ALERT, c->log, 0, "SSL_set_fd() failed");
        return NGX_ERROR;
    }*/
    sc->rbio_mem = BIO_new(BIO_s_mem());
    sc->wbio_mem = BIO_new(BIO_s_mem());
    SSL_set_bio(sc->connection, sc->rbio_mem, sc->wbio_mem);

    if (flags & NGX_SSL_CLIENT) {
        SSL_set_connect_state(sc->connection);

    } else {
        SSL_set_accept_state(sc->connection);

#ifdef SSL_OP_NO_RENEGOTIATION
        SSL_set_options(sc->connection, SSL_OP_NO_RENEGOTIATION);
#endif
    }

    if (SSL_set_ex_data(sc->connection, ngx_ssl_connection_index, c) == 0) {
        ngx_ssl_error(NGX_LOG_ALERT, c->log, 0, "SSL_set_ex_data() failed");
        return NGX_ERROR;
    }

    c->ssl = sc;

#if (NGX_DEBUG)
    // debug
    output_debug_string("\nngx_ssl_create_connectionex(): rbio_mem(0x%08x)wbio_mem(0x%08x), ssl(0x%08x)rbio(0x%08x)wbio(0x%08x)bbio(0x%08x) on -- c(%d)fd(%d)destroyed(%d)_r(0x%08x)w(0x%08x)c(0x%08x) ... ssl_flags(%d)\n",
        (uintptr_t)c->ssl->rbio_mem, (uintptr_t)c->ssl->wbio_mem,
        (uintptr_t)c->ssl->connection, (uintptr_t)c->ssl->connection->rbio, (uintptr_t)c->ssl->connection->wbio, (uintptr_t)c->ssl->connection->bbio,
        c->id, c->fd, c->destroyed, (uintptr_t)c->read, (uintptr_t)c->write, (uintptr_t)c, flags);
#endif

    return NGX_OK;
}


ngx_int_t
ngx_ssl_handshakeex(ngx_connection_t *c)
{
    int        n, sslerr;
    ngx_err_t  err;
    ngx_buf_t *b;
    ngx_int_t  rc;

    size_t     size;
    int        ssl_ret;

    if (!c->read->ready) {
        return NGX_AGAIN;
    }

    ngx_ssl_clear_errorex(c->log);

    b = c->buffer;

    if (b != NULL && b->pos < b->last) {
        /* data read by ngx_acceptex() */
        n = (b->last - b->pos);
    }
    else {
        size = NGX_SSL_MAX_SESSION_SIZE;

        /* recv */
        if (b == NULL) {
            b = ngx_create_temp_buf(c->pool, size);
            if (b == NULL) {
                return NGX_ERROR;
            }

            c->buffer = b;

        }
        else if (b->start == NULL) {

            b->start = ngx_palloc(c->pool, size);
            if (b->start == NULL) {
                return NGX_ERROR;
            }

            b->pos = b->start;
            b->last = b->start;
            b->end = b->last + size;
        }

        n = ngx_recv(c, b->last, size);

        if (n == NGX_AGAIN
            || n == NGX_ERROR) {
            return n;
        }

        /* data completed by ngx_overlapped_wsarecv() */
        b->last += n;
    }

    /* handle rbio_mem(SSL_read) */
    ssl_ret = 0;
    if (n > 0) {
        size = n;
        ssl_ret = BIO_write(c->ssl->rbio_mem, b->pos, size);
        if (ssl_ret <= 0) {
            sslerr = SSL_get_error(c->ssl->connection, ssl_ret);
            if (is_ssl_error(sslerr)) {
                return NGX_ERROR;
            }
            return NGX_AGAIN;
        }

        b->pos += n;
    }

#if (NGX_DEBUG)
    // debug
    output_debug_string("\nngx_ssl_handshakeex(): rbio_mem(0x%08x)wbio_mem(0x%08x), ssl(0x%08x)rbio(0x%08x)wbio(0x%08x)bbio(0x%08x) on -- c(%d)fd(%d)destroyed(%d)_r(0x%08x)w(0x%08x)c(0x%08x)\n",
        (uintptr_t)c->ssl->rbio_mem, (uintptr_t)c->ssl->wbio_mem,
        (uintptr_t)c->ssl->connection, (uintptr_t)c->ssl->connection->rbio, (uintptr_t)c->ssl->connection->wbio, (uintptr_t)c->ssl->connection->bbio,
        c->id, c->fd, c->destroyed, (uintptr_t)c->read, (uintptr_t)c->write, (uintptr_t)c);
#endif

    n = SSL_do_handshake(c->ssl->connection);

    ngx_log_debug1(NGX_LOG_DEBUG_EVENT, c->log, 0, "SSL_do_handshake: %d", n);

    if (n == 1) {

        if (b->pos != b->last) {
            /* ssl handshake buffer must be empty */
            ngx_log_error(NGX_LOG_ERR, c->log, 0,
                "ngx_ssl_handshakeex failed -- ssl handshake buffer must be empty when shakehand ok");
            return NGX_ERROR;
        }

        /* post IOCP read event */
        NGX_SSL_POST_IOCP_READ_EVENT(c);

        /* handle wbio_mem(via SSL_write) */
        rc = ngx_ssl_bio_mem_send(c->ssl, c);
        if (NGX_OK != rc) {
            return NGX_ERROR;
        }

#if (NGX_DEBUG)
        ngx_ssl_handshake_logex(c);
#endif

        c->ssl->handshaked = 1;

        c->recv = ngx_ssl_recvex;
        c->send = ngx_ssl_writeex;
        c->recv_chain = ngx_ssl_recv_chainex;
        c->send_chain = ngx_ssl_send_chainex;

#ifndef SSL_OP_NO_RENEGOTIATION
#if OPENSSL_VERSION_NUMBER < 0x10100000L
#ifdef SSL3_FLAGS_NO_RENEGOTIATE_CIPHERS

        /* initial handshake done, disable renegotiation (CVE-2009-3555) */
        if (c->ssl->connection->s3 && SSL_is_server(c->ssl->connection)) {
            c->ssl->connection->s3->flags |= SSL3_FLAGS_NO_RENEGOTIATE_CIPHERS;
        }

#endif
#endif
#endif

#if (NGX_DEBUG)
        // debug
        output_debug_string("\nngx_ssl_handshakeex(): handshake ok, rbio_mem(0x%08x)wbio_mem(0x%08x), ssl(0x%08x)rbio(0x%08x)wbio(0x%08x)bbio(0x%08x) on -- c(%d)fd(%d)destroyed(%d)_r(0x%08x)w(0x%08x)c(0x%08x)\n",
            (uintptr_t)c->ssl->rbio_mem, (uintptr_t)c->ssl->wbio_mem,
            (uintptr_t)c->ssl->connection, (uintptr_t)c->ssl->connection->rbio, (uintptr_t)c->ssl->connection->wbio, (uintptr_t)c->ssl->connection->bbio,
            c->id, c->fd, c->destroyed, (uintptr_t)c->read, (uintptr_t)c->write, (uintptr_t)c);
#endif
        return NGX_OK;
    }

    sslerr = SSL_get_error(c->ssl->connection, n);

    ngx_log_debug1(NGX_LOG_DEBUG_EVENT, c->log, 0, "SSL_get_error: %d", sslerr);

    if (sslerr == SSL_ERROR_WANT_READ) {

        c->read->handler = ngx_ssl_handshake_handlerex;
        c->write->handler = ngx_ssl_handshake_handlerex;

        /* post IOCP read event */
        NGX_SSL_POST_IOCP_READ_EVENT(c);

        /* handle wbio_mem(via SSL_write) */
        rc = ngx_ssl_bio_mem_send(c->ssl, c);
        if (NGX_OK != rc) {
            return NGX_ERROR;
        }

        return NGX_AGAIN;
    }

    if (sslerr == SSL_ERROR_WANT_WRITE) {

        c->read->handler = ngx_ssl_handshake_handlerex;
        c->write->handler = ngx_ssl_handshake_handlerex;

        /* post IOCP read event */
        NGX_SSL_POST_IOCP_READ_EVENT(c);

        /* handle wbio_mem(via SSL_write) */
        rc = ngx_ssl_bio_mem_send(c->ssl, c);
        if (NGX_OK != rc) {
            return NGX_ERROR;
        }
        return NGX_AGAIN;
    }

#if OPENSSL_VERSION_NUMBER >= 0x10002000L
    if (sslerr == SSL_ERROR_WANT_X509_LOOKUP
#   ifdef SSL_ERROR_PENDING_SESSION
        || sslerr == SSL_ERROR_PENDING_SESSION
#   endif
       )
    {
        c->read->handler = ngx_ssl_handshake_handlerex;
        c->write->handler = ngx_ssl_handshake_handlerex;

        /* post IOCP read event */
        NGX_SSL_POST_IOCP_READ_EVENT(c);

        /* handle wbio_mem(via SSL_write) */
        rc = ngx_ssl_bio_mem_send(c->ssl, c);
        if (NGX_OK != rc) {
            return NGX_ERROR;
        }
        return NGX_AGAIN;
    }
#endif

    err = (sslerr == SSL_ERROR_SYSCALL) ? ngx_errno : 0;

    c->ssl->no_wait_shutdown = 1;
    c->ssl->no_send_shutdown = 1;
    c->read->eof = 1;

    if (sslerr == SSL_ERROR_ZERO_RETURN || ERR_peek_error() == 0) {
        ngx_connection_error(c, err,
                             "peer closed connection in SSL handshake");

        return NGX_ERROR;
    }

    c->read->error = 1;

    ngx_ssl_connection_errorex(c, sslerr, err, "SSL_do_handshake() failed");

    return NGX_ERROR;
}


#if (NGX_DEBUG)

static void
ngx_ssl_handshake_logex(ngx_connection_t *c)
{
    char         buf[129], *s, *d;
#if OPENSSL_VERSION_NUMBER >= 0x10000000L
    const
#endif
    SSL_CIPHER  *cipher;

    cipher = SSL_get_current_cipher(c->ssl->connection);

    if (cipher) {
        SSL_CIPHER_description(cipher, &buf[1], 128);

        for (s = &buf[1], d = buf; *s; s++) {
            if (*s == ' ' && *d == ' ') {
                continue;
            }

            if (*s == LF || *s == CR) {
                continue;
            }

            *++d = *s;
        }

        if (*d != ' ') {
            d++;
        }

        *d = '\0';

        ngx_log_debug2(NGX_LOG_DEBUG_EVENT, c->log, 0,
                       "SSL: %s, cipher: \"%s\"",
                       SSL_get_version(c->ssl->connection), &buf[1]);

        if (SSL_session_reused(c->ssl->connection)) {
            ngx_log_debug0(NGX_LOG_DEBUG_EVENT, c->log, 0,
                           "SSL reused session");
        }

    } else {
        ngx_log_debug0(NGX_LOG_DEBUG_EVENT, c->log, 0,
                       "SSL no shared ciphers");
    }
}

#endif


static void
ngx_ssl_handshake_handlerex(ngx_event_t *ev)
{
    ngx_connection_t  *c;

    c = ev->data;

    ngx_log_debug1(NGX_LOG_DEBUG_EVENT, c->log, 0,
                   "SSL handshake handler: %d", ev->write);

    if (ev->timedout) {
        c->ssl->handler(c);
        return;
    }

    if (ngx_ssl_handshakeex(c) == NGX_AGAIN) {
        return;
    }

    c->ssl->handler(c);
}


ssize_t
ngx_ssl_recv_chainex(ngx_connection_t *c, ngx_chain_t *cl, off_t limit)
{
    u_char     *last;
    ssize_t     n, bytes, size;
    ngx_buf_t  *b;

    bytes = 0;

    b = cl->buf;
    last = b->last;

    for ( ;; ) {
        size = b->end - last;

        if (limit) {
            if (bytes >= limit) {
                return bytes;
            }

            if (bytes + size > limit) {
                size = (ssize_t) (limit - bytes);
            }
        }

        n = ngx_ssl_recvex(c, last, size);

        if (n > 0) {
            last += n;
            bytes += n;

            if (last == b->end) {
                cl = cl->next;

                if (cl == NULL) {
                    return bytes;
                }

                b = cl->buf;
                last = b->last;
            }

            continue;
        }

        if (bytes) {

            /* post IOCP read event with buf */
            NGX_SSL_POST_IOCP_READ_EVENT_WITH_BUF(c, b);

            return bytes;
        }

        return n;
    }
}


ssize_t
ngx_ssl_recvex(ngx_connection_t *c, u_char *buf, size_t size)
{
    int     n, bytes;
    int     ssl_ret, sslerr, ssl_read_num;

#if (NGX_DEBUG)
    u_char *ssl_buf;
    size_t  ssl_buf_size;
#endif

    if (!c->read->ready) {
        return NGX_AGAIN;
    }

#ifdef SSL_READ_EARLY_DATA_SUCCESS
    if (c->ssl->in_early) {
        return ngx_ssl_recv_early(c, buf, size);
    }
#endif

    if (c->ssl->last == NGX_ERROR) {
        c->read->error = 1;
        return NGX_ERROR;
    }

    if (c->ssl->last == NGX_DONE) {
        c->read->ready = 0;
        c->read->eof = 1;
        return 0;
    }

    bytes = 0;

    ngx_ssl_clear_errorex(c->log);

#if (NGX_DEBUG)
    ssl_buf = buf;
    ssl_buf_size = size;
#endif

    ssl_ret = 0;

    do {

        n = ngx_recv(c, buf, size);

        if (n == NGX_AGAIN
            || n == NGX_ERROR) {
            return n;
        }

        if (0 == n) {
            return 0;
        }

        ssl_ret = BIO_write(c->ssl->rbio_mem, buf, n);
        if (ssl_ret <= 0) {
            sslerr = SSL_get_error(c->ssl->connection, ssl_ret);
            if (is_ssl_error(sslerr)) {
                return NGX_ERROR;
            }
            return NGX_AGAIN;
        }

        /*
         * SSL_read() may return data in parts, so try to read
         * until SSL_read() would return no data
         */

        for ( ;; ) {

            ssl_read_num = SSL_read(c->ssl->connection, buf, size);

            ngx_log_debug1(NGX_LOG_DEBUG_EVENT, c->log, 0, "SSL_read: %d", ssl_read_num);

            if (ssl_read_num > 0) {
                bytes += ssl_read_num;
            }

            c->ssl->last = ngx_ssl_handle_recvex(c, ssl_read_num);

            if (c->ssl->last == NGX_OK) {

                size -= ssl_read_num;

                if (size == 0) {
                    /* NORMALLY, size MUST NOT be zero, the SSL_read data size can't be exactly equal buf size(it MUST be overflow whe "size == 0") */
#if (NGX_DEBUG)
                    // debug
                    {
                        char data[8192] = { 0 };
                        size_t len = ngx_min(sizeof(data) - 1, bytes);
                        char *p;
                        memcpy(data, ssl_buf, len);
                        output_debug_string("\n\t>>>> SSL_read !!!!!!overflow!!!!!! begin\n");
                        output_debug_string("\t     c(%d)fd(%d)destroyed(%d)\n\t     bytes(%d/%d) -- data: \n\n%s\n",
                            c->id, c->fd, c->destroyed,
                            (int)len, bytes,
                            data);
                        p = ngx_hex_dump((u_char *)data, (u_char *)ssl_buf, len);
                        *p = '\0';
                        output_debug_string("\tdata_hex: \n\n%s\n", data);
                        output_debug_string("\n\t<<<< SSL_read !!!!!!overflow!!!!!! end\n\n");
                    }
#endif
                    return NGX_ERROR;
                }

                buf += ssl_read_num;

                continue;
            }

            if (bytes) {
#if (NGX_DEBUG)
                    // debug
                    {
                        char data[8192] = { 0 };
                        size_t len = ngx_min(sizeof(data) - 1, bytes);
                        char *p;
                        memcpy(data, ssl_buf, len);
                        output_debug_string("\n\t>>>> SSL_read begin\n");
                        output_debug_string("\t     c(%d)fd(%d)destroyed(%d)\n\t     bytes(%d/%d) -- data: \n\n%s\n",
                            c->id, c->fd, c->destroyed,
                            (int)len, bytes,
                            data);
                        p = ngx_hex_dump((u_char *)data, (u_char *)ssl_buf, len);
                        *p = '\0';
                        output_debug_string("\tdata_hex: \n\n%s\n", data);
                        output_debug_string("\n\t<<<< SSL_read end\n\n");
                    }
#endif
                return bytes;
            }

            switch (c->ssl->last) {

            case NGX_DONE:
                c->read->ready = 0;
                c->read->eof = 1;
                return 0;

            case NGX_ERROR:
#if (NGX_DEBUG)
                // debug
                output_debug_string("\nngx_ssl_recvex(): SSL_read() parse input data failed, rbio_mem(0x%08x)wbio_mem(0x%08x), ssl(0x%08x)rbio(0x%08x)wbio(0x%08x)bbio(0x%08x) on -- c(%d)fd(%d)destroyed(%d)_r(0x%08x)w(0x%08x)c(0x%08x)\n",
                    (uintptr_t)c->ssl->rbio_mem, (uintptr_t)c->ssl->wbio_mem,
                    (uintptr_t)c->ssl->connection, (uintptr_t)c->ssl->connection->rbio, (uintptr_t)c->ssl->connection->wbio, (uintptr_t)c->ssl->connection->bbio,
                    c->id, c->fd, c->destroyed, (uintptr_t)c->read, (uintptr_t)c->write, (uintptr_t)c);
#endif
                c->read->error = 1;

                /* fall through */

            case NGX_AGAIN:
                return c->ssl->last;
            }
        }

    } while (1);

    return NGX_ERROR;
}


static ngx_int_t
ngx_ssl_handle_recvex(ngx_connection_t *c, int n)
{
    int        sslerr;
    ngx_err_t  err;
    ngx_int_t  rc;

#ifndef SSL_OP_NO_RENEGOTIATION

    if (c->ssl->renegotiation) {
         /*
          * disable renegotiation (CVE-2009-3555):
          * OpenSSL (at least up to 0.9.8l) does not handle disabled
          * renegotiation gracefully, so drop connection here
          */

        ngx_log_error(NGX_LOG_NOTICE, c->log, 0, "SSL renegotiation disabled");

        while (ERR_peek_error()) {
            ngx_ssl_error(NGX_LOG_DEBUG, c->log, 0,
                          "ignoring stale global SSL error");
        }

        ERR_clear_error();

        c->ssl->no_wait_shutdown = 1;
        c->ssl->no_send_shutdown = 1;

        return NGX_ERROR;
    }

#endif

    if (n > 0) {

        if (c->ssl->saved_write_handler) {

            c->write->handler = c->ssl->saved_write_handler;
            c->ssl->saved_write_handler = NULL;

            ngx_post_event(c->write, &ngx_posted_events);
        }

        /* handle wbio_mem(via SSL_write) */
        rc = ngx_ssl_bio_mem_send(c->ssl, c);
        if (NGX_OK != rc) {
            return NGX_ERROR;
        }
        return NGX_OK;
    }

    sslerr = SSL_get_error(c->ssl->connection, n);

    err = (sslerr == SSL_ERROR_SYSCALL) ? ngx_errno : 0;

    ngx_log_debug1(NGX_LOG_DEBUG_EVENT, c->log, 0, "SSL_get_error: %d", sslerr);

    if (sslerr == SSL_ERROR_WANT_READ) {

        if (c->ssl->saved_write_handler) {

            c->write->handler = c->ssl->saved_write_handler;
            c->ssl->saved_write_handler = NULL;
  
            /* handle wbio_mem(via SSL_write) */
            rc = ngx_ssl_bio_mem_send(c->ssl, c);
            if (NGX_OK != rc) {
                return NGX_ERROR;
            }
        }

        return NGX_AGAIN;
    }

    if (sslerr == SSL_ERROR_WANT_WRITE) {

        ngx_log_debug0(NGX_LOG_DEBUG_EVENT, c->log, 0,
                       "SSL_read: want write");

        /* handle wbio_mem(via SSL_write) */
        rc = ngx_ssl_bio_mem_send(c->ssl, c);
        if (NGX_OK != rc) {
            return NGX_ERROR;
        }

        /*
         * we do not set the timer because there is already the read event timer
         */

        if (c->ssl->saved_write_handler == NULL) {
            c->ssl->saved_write_handler = c->write->handler;
            c->write->handler = ngx_ssl_write_handlerex;
        }

        return NGX_AGAIN;
    }

    c->ssl->no_wait_shutdown = 1;
    c->ssl->no_send_shutdown = 1;

    if (sslerr == SSL_ERROR_ZERO_RETURN || ERR_peek_error() == 0) {
        ngx_log_debug0(NGX_LOG_DEBUG_EVENT, c->log, 0,
                       "peer shutdown SSL cleanly");

        /* handle wbio_mem(via SSL_write) */
        rc = ngx_ssl_bio_mem_send(c->ssl, c);
        if (NGX_OK != rc) {
            return NGX_ERROR;
        }
        return NGX_DONE;
    }

    ngx_ssl_connection_errorex(c, sslerr, err, "SSL_read() failed");

    return NGX_ERROR;
}


static void
ngx_ssl_write_handlerex(ngx_event_t *wev)
{
    ngx_connection_t  *c;

    c = wev->data;

    ngx_log_debug0(NGX_LOG_DEBUG_EVENT, c->log, 0, "SSL write handler");

    c->read->handler(c->read);
}


/*
 * OpenSSL has no SSL_writev() so we copy several bufs into our 16K buffer
 * before the SSL_write() call to decrease a SSL overhead.
 *
 * Besides for protocols such as HTTP it is possible to always buffer
 * the output to decrease a SSL overhead some more.
 */

ngx_chain_t *
ngx_ssl_send_chainex(ngx_connection_t *c, ngx_chain_t *in, off_t limit)
{
    int          n;
    ngx_uint_t   flush;
    ssize_t      send, size;
    ngx_buf_t   *buf;

    if (!c->ssl->buffer) {

        while (in) {
            if (ngx_buf_special(in->buf)) {
                in = in->next;
                continue;
            }

            n = ngx_ssl_writeex(c, in->buf->pos, in->buf->last - in->buf->pos);

            if (n == NGX_ERROR) {
                return NGX_CHAIN_ERROR;
            }

            if (n == NGX_AGAIN) {
                return in;
            }

            in->buf->pos += n;

            if (in->buf->pos == in->buf->last) {
                in = in->next;
            }
        }

        return in;
    }


    /* the maximum limit size is the maximum int32_t value - the page size */

    if (limit == 0 || limit > (off_t)(NGX_MAX_INT32_VALUE - ngx_pagesize)) {
        limit = NGX_MAX_INT32_VALUE - ngx_pagesize;
    }

    buf = c->ssl->buf;

    if (buf == NULL) {
        buf = ngx_create_temp_buf(c->pool, c->ssl->buffer_size);
        if (buf == NULL) {
            return NGX_CHAIN_ERROR;
        }

        c->ssl->buf = buf;
    }

    if (buf->start == NULL) {
        buf->start = ngx_palloc(c->pool, c->ssl->buffer_size);
        if (buf->start == NULL) {
            return NGX_CHAIN_ERROR;
        }

        buf->pos = buf->start;
        buf->last = buf->start;
        buf->end = buf->start + c->ssl->buffer_size;
    }

    send = buf->last - buf->pos;
    flush = (in == NULL) ? 1 : buf->flush;

    for ( ;; ) {

        while (in && buf->last < buf->end && send < limit) {
            if (in->buf->last_buf || in->buf->flush) {
                flush = 1;
            }

            if (ngx_buf_special(in->buf)) {
                in = in->next;
                continue;
            }

            size = in->buf->last - in->buf->pos;

            if (size > buf->end - buf->last) {
                size = buf->end - buf->last;
            }

            if (send + size > limit) {
                size = (ssize_t) (limit - send);
            }

             ngx_log_debug1(NGX_LOG_DEBUG_EVENT, c->log, 0,
                           "SSL buf copy: %z", size);

            ngx_memcpy(buf->last, in->buf->pos, size);

            buf->last += size;
            in->buf->pos += size;
            send += size;

            if (in->buf->pos == in->buf->last) {
                in = in->next;
            }
        }

        if (!flush && send < limit && buf->last < buf->end) {
            break;
        }

        size = buf->last - buf->pos;

        if (size == 0) {
            buf->flush = 0;
            c->buffered &= ~NGX_SSL_BUFFERED;
            return in;
        }

        n = ngx_ssl_writeex(c, buf->pos, size);

        if (n == NGX_ERROR) {
            return NGX_CHAIN_ERROR;
        }

        if (n == NGX_AGAIN) {
            break;
        }

        buf->pos += n;

        if (n < size) {
            break;
        }

        flush = 0;

        buf->pos = buf->start;
        buf->last = buf->start;

        if (in == NULL || send == limit) {
            break;
        }
    }

    buf->flush = flush;

    if (buf->pos < buf->last) {
        c->buffered |= NGX_SSL_BUFFERED;

    } else {
        c->buffered &= ~NGX_SSL_BUFFERED;
    }

    return in;
}


ssize_t
ngx_ssl_writeex(ngx_connection_t *c, u_char *data, size_t size)
{
    int        n, sslerr;
    ngx_err_t  err;
    ngx_int_t  rc;

#ifdef SSL_READ_EARLY_DATA_SUCCESS
    if (c->ssl->in_early) {
        return ngx_ssl_write_early(c, data, size);
    }
#endif

    ngx_ssl_clear_errorex(c->log);

    ngx_log_debug1(NGX_LOG_DEBUG_EVENT, c->log, 0, "SSL to write: %uz", size);

    n = SSL_write(c->ssl->connection, data, size);

    ngx_log_debug1(NGX_LOG_DEBUG_EVENT, c->log, 0, "SSL_write: %d", n);

    if (n > 0) {

        if (c->ssl->saved_read_handler) {

            c->read->handler = c->ssl->saved_read_handler;
            c->ssl->saved_read_handler = NULL;

            /* post IOCP read event */
            NGX_SSL_POST_IOCP_READ_EVENT(c);
        }

        c->sent += n;

        /* handle wbio_mem(via SSL_write) */
        rc = ngx_ssl_bio_mem_send(c->ssl, c);
        if (NGX_OK != rc) {
            return NGX_ERROR;
        }
        return n;
    }

    sslerr = SSL_get_error(c->ssl->connection, n);

    err = (sslerr == SSL_ERROR_SYSCALL) ? ngx_errno : 0;

    ngx_log_debug1(NGX_LOG_DEBUG_EVENT, c->log, 0, "SSL_get_error: %d", sslerr);

    if (sslerr == SSL_ERROR_WANT_WRITE) {

        if (c->ssl->saved_read_handler) {

            c->read->handler = c->ssl->saved_read_handler;
            c->ssl->saved_read_handler = NULL;
            
            /* post IOCP read event */
            NGX_SSL_POST_IOCP_READ_EVENT(c);
        }

        /* handle wbio_mem(via SSL_write) */
        rc = ngx_ssl_bio_mem_send(c->ssl, c);
        if (NGX_OK != rc) {
            return NGX_ERROR;
        }
        return NGX_AGAIN;
    }

    if (sslerr == SSL_ERROR_WANT_READ) {

        ngx_log_debug0(NGX_LOG_DEBUG_EVENT, c->log, 0,
                       "SSL_write: want read");

        /*
         * we do not set the timer because there is already
         * the write event timer
         */

        if (c->ssl->saved_read_handler == NULL) {
            c->ssl->saved_read_handler = c->read->handler;
            c->read->handler = ngx_ssl_read_handlerex;
        }

        /* handle wbio_mem(via SSL_write) */
        rc = ngx_ssl_bio_mem_send(c->ssl, c);
        if (NGX_OK != rc) {
            return NGX_ERROR;
        }
        return NGX_AGAIN;
    }

    c->ssl->no_wait_shutdown = 1;
    c->ssl->no_send_shutdown = 1;
    c->write->error = 1;

    ngx_ssl_connection_errorex(c, sslerr, err, "SSL_write() failed");

    return NGX_ERROR;
}


static void
ngx_ssl_read_handlerex(ngx_event_t *rev)
{
    ngx_connection_t  *c;

    c = rev->data;

    ngx_log_debug0(NGX_LOG_DEBUG_EVENT, c->log, 0, "SSL read handler");

    c->write->handler(c->write);
}


ngx_int_t
ngx_ssl_shutdownex(ngx_connection_t *c)
{
    int        n, sslerr, mode;
    ngx_err_t  err;
    ngx_int_t  rc;

#if (NGX_DEBUG)
    // debug
    output_debug_string("\nngx_ssl_shutdownex(): rbio_mem(0x%08x)wbio_mem(0x%08x), ssl(0x%08x)rbio(0x%08x)wbio(0x%08x)bbio(0x%08x) on -- c(%d)fd(%d)destroyed(%d)_r(0x%08x)w(0x%08x)c(0x%08x)\n",
        (uintptr_t)c->ssl->rbio_mem, (uintptr_t)c->ssl->wbio_mem,
        (uintptr_t)c->ssl->connection, (uintptr_t)c->ssl->connection->rbio, (uintptr_t)c->ssl->connection->wbio, (uintptr_t)c->ssl->connection->bbio,
        c->id, c->fd, c->destroyed, (uintptr_t)c->read, (uintptr_t)c->write, (uintptr_t)c);
#endif

    if (SSL_in_init(c->ssl->connection)) {
        /*
         * OpenSSL 1.0.2f complains if SSL_shutdown() is called during
         * an SSL handshake, while previous versions always return 0.
         * Avoid calling SSL_shutdown() if handshake wasn't completed.
         */

        SSL_free(c->ssl->connection);
        c->ssl = NULL;

        return NGX_OK;
    }

    if (c->timedout) {
        mode = SSL_RECEIVED_SHUTDOWN|SSL_SENT_SHUTDOWN;
        SSL_set_quiet_shutdown(c->ssl->connection, 1);

    } else {
        mode = SSL_get_shutdown(c->ssl->connection);

        if (c->ssl->no_wait_shutdown) {
            mode |= SSL_RECEIVED_SHUTDOWN;
        }

        if (c->ssl->no_send_shutdown) {
            mode |= SSL_SENT_SHUTDOWN;
        }

        if (c->ssl->no_wait_shutdown && c->ssl->no_send_shutdown) {
            SSL_set_quiet_shutdown(c->ssl->connection, 1);
        }
    }

    SSL_set_shutdown(c->ssl->connection, mode);

    ngx_ssl_clear_errorex(c->log);

    n = SSL_shutdown(c->ssl->connection);

    ngx_log_debug1(NGX_LOG_DEBUG_EVENT, c->log, 0, "SSL_shutdown: %d", n);

    sslerr = 0;

    /* before 0.9.8m SSL_shutdown() returned 0 instead of -1 on errors */

    if (n != 1 && ERR_peek_error()) {
        sslerr = SSL_get_error(c->ssl->connection, n);

        ngx_log_debug1(NGX_LOG_DEBUG_EVENT, c->log, 0,
                       "SSL_get_error: %d", sslerr);
    }

    if (n == 1 || sslerr == 0 || sslerr == SSL_ERROR_ZERO_RETURN) {
        SSL_free(c->ssl->connection);
        c->ssl = NULL;

        return NGX_OK;
    }

    if (sslerr == SSL_ERROR_WANT_READ || sslerr == SSL_ERROR_WANT_WRITE) {
        c->read->handler = ngx_ssl_shutdown_handlerex;
        c->write->handler = ngx_ssl_shutdown_handlerex;

        /* post IOCP read event */
        NGX_SSL_POST_IOCP_READ_EVENT(c);

        /* handle wbio_mem(via SSL_write) */
        rc = ngx_ssl_bio_mem_send(c->ssl, c);
        if (NGX_OK != rc) {
            return NGX_ERROR;
        }

        if (sslerr == SSL_ERROR_WANT_READ) {
            ngx_add_timer(c->read, 30000);
        }

        return NGX_AGAIN;
    }

    err = (sslerr == SSL_ERROR_SYSCALL) ? ngx_errno : 0;

    ngx_ssl_connection_errorex(c, sslerr, err, "SSL_shutdown() failed");

    SSL_free(c->ssl->connection);
    c->ssl = NULL;

    return NGX_ERROR;
}


static void
ngx_ssl_shutdown_handlerex(ngx_event_t *ev)
{
    ngx_connection_t           *c;
    ngx_connection_handler_pt   handler;

    c = ev->data;
    handler = c->ssl->handler;

    if (ev->timedout) {
        c->timedout = 1;
    }

    ngx_log_debug0(NGX_LOG_DEBUG_EVENT, ev->log, 0, "SSL shutdown handler");

    if (ngx_ssl_shutdownex(c) == NGX_AGAIN) {
        return;
    }

    handler(c);
}


static void
ngx_ssl_connection_errorex(ngx_connection_t *c, int sslerr, ngx_err_t err,
    char *text)
{
    int         n;
    ngx_uint_t  level;

    level = NGX_LOG_CRIT;

    if (sslerr == SSL_ERROR_SYSCALL) {

        if (err == NGX_ECONNRESET
            || err == NGX_EPIPE
            || err == NGX_ENOTCONN
            || err == NGX_ETIMEDOUT
            || err == NGX_ECONNREFUSED
            || err == NGX_ENETDOWN
            || err == NGX_ENETUNREACH
            || err == NGX_EHOSTDOWN
            || err == NGX_EHOSTUNREACH)
        {
            switch (c->log_error) {

            case NGX_ERROR_IGNORE_ECONNRESET:
            case NGX_ERROR_INFO:
                level = NGX_LOG_INFO;
                break;

            case NGX_ERROR_ERR:
                level = NGX_LOG_ERR;
                break;

            default:
                break;
            }
        }

    } else if (sslerr == SSL_ERROR_SSL) {

        n = ERR_GET_REASON(ERR_peek_error());

            /* handshake failures */
        if (n == SSL_R_BAD_CHANGE_CIPHER_SPEC                        /*  103 */
#ifdef SSL_R_NO_SUITABLE_KEY_SHARE
            || n == SSL_R_NO_SUITABLE_KEY_SHARE                      /*  101 */
#endif
#ifdef SSL_R_NO_SUITABLE_SIGNATURE_ALGORITHM
            || n == SSL_R_NO_SUITABLE_SIGNATURE_ALGORITHM            /*  118 */
#endif
            || n == SSL_R_BLOCK_CIPHER_PAD_IS_WRONG                  /*  129 */
            || n == SSL_R_DIGEST_CHECK_FAILED                        /*  149 */
            || n == SSL_R_ERROR_IN_RECEIVED_CIPHER_LIST              /*  151 */
            || n == SSL_R_EXCESSIVE_MESSAGE_SIZE                     /*  152 */
            || n == SSL_R_HTTPS_PROXY_REQUEST                        /*  155 */
            || n == SSL_R_HTTP_REQUEST                               /*  156 */
            || n == SSL_R_LENGTH_MISMATCH                            /*  159 */
#ifdef SSL_R_NO_CIPHERS_PASSED
            || n == SSL_R_NO_CIPHERS_PASSED                          /*  182 */
#endif
            || n == SSL_R_NO_CIPHERS_SPECIFIED                       /*  183 */
            || n == SSL_R_NO_COMPRESSION_SPECIFIED                   /*  187 */
            || n == SSL_R_NO_SHARED_CIPHER                           /*  193 */
            || n == SSL_R_RECORD_LENGTH_MISMATCH                     /*  213 */
#ifdef SSL_R_PARSE_TLSEXT
            || n == SSL_R_PARSE_TLSEXT                               /*  227 */
#endif
            || n == SSL_R_UNEXPECTED_MESSAGE                         /*  244 */
            || n == SSL_R_UNEXPECTED_RECORD                          /*  245 */
            || n == SSL_R_UNKNOWN_ALERT_TYPE                         /*  246 */
            || n == SSL_R_UNKNOWN_PROTOCOL                           /*  252 */
#ifdef SSL_R_NO_COMMON_SIGNATURE_ALGORITHMS
            || n == SSL_R_NO_COMMON_SIGNATURE_ALGORITHMS             /*  253 */
#endif
            || n == SSL_R_UNSUPPORTED_PROTOCOL                       /*  258 */
#ifdef SSL_R_NO_SHARED_GROUP
            || n == SSL_R_NO_SHARED_GROUP                            /*  266 */
#endif
            || n == SSL_R_WRONG_VERSION_NUMBER                       /*  267 */
            || n == SSL_R_DECRYPTION_FAILED_OR_BAD_RECORD_MAC        /*  281 */
#ifdef SSL_R_RENEGOTIATE_EXT_TOO_LONG
            || n == SSL_R_RENEGOTIATE_EXT_TOO_LONG                   /*  335 */
            || n == SSL_R_RENEGOTIATION_ENCODING_ERR                 /*  336 */
            || n == SSL_R_RENEGOTIATION_MISMATCH                     /*  337 */
#endif
#ifdef SSL_R_UNSAFE_LEGACY_RENEGOTIATION_DISABLED
            || n == SSL_R_UNSAFE_LEGACY_RENEGOTIATION_DISABLED       /*  338 */
#endif
#ifdef SSL_R_SCSV_RECEIVED_WHEN_RENEGOTIATING
            || n == SSL_R_SCSV_RECEIVED_WHEN_RENEGOTIATING           /*  345 */
#endif
#ifdef SSL_R_INAPPROPRIATE_FALLBACK
            || n == SSL_R_INAPPROPRIATE_FALLBACK                     /*  373 */
#endif
#ifdef SSL_R_VERSION_TOO_LOW
            || n == SSL_R_VERSION_TOO_LOW                            /*  396 */
#endif
            || n == 1000 /* SSL_R_SSLV3_ALERT_CLOSE_NOTIFY */
#ifdef SSL_R_SSLV3_ALERT_UNEXPECTED_MESSAGE
            || n == SSL_R_SSLV3_ALERT_UNEXPECTED_MESSAGE             /* 1010 */
            || n == SSL_R_SSLV3_ALERT_BAD_RECORD_MAC                 /* 1020 */
            || n == SSL_R_TLSV1_ALERT_DECRYPTION_FAILED              /* 1021 */
            || n == SSL_R_TLSV1_ALERT_RECORD_OVERFLOW                /* 1022 */
            || n == SSL_R_SSLV3_ALERT_DECOMPRESSION_FAILURE          /* 1030 */
            || n == SSL_R_SSLV3_ALERT_HANDSHAKE_FAILURE              /* 1040 */
            || n == SSL_R_SSLV3_ALERT_NO_CERTIFICATE                 /* 1041 */
            || n == SSL_R_SSLV3_ALERT_BAD_CERTIFICATE                /* 1042 */
            || n == SSL_R_SSLV3_ALERT_UNSUPPORTED_CERTIFICATE        /* 1043 */
            || n == SSL_R_SSLV3_ALERT_CERTIFICATE_REVOKED            /* 1044 */
            || n == SSL_R_SSLV3_ALERT_CERTIFICATE_EXPIRED            /* 1045 */
            || n == SSL_R_SSLV3_ALERT_CERTIFICATE_UNKNOWN            /* 1046 */
            || n == SSL_R_SSLV3_ALERT_ILLEGAL_PARAMETER              /* 1047 */
            || n == SSL_R_TLSV1_ALERT_UNKNOWN_CA                     /* 1048 */
            || n == SSL_R_TLSV1_ALERT_ACCESS_DENIED                  /* 1049 */
            || n == SSL_R_TLSV1_ALERT_DECODE_ERROR                   /* 1050 */
            || n == SSL_R_TLSV1_ALERT_DECRYPT_ERROR                  /* 1051 */
            || n == SSL_R_TLSV1_ALERT_EXPORT_RESTRICTION             /* 1060 */
            || n == SSL_R_TLSV1_ALERT_PROTOCOL_VERSION               /* 1070 */
            || n == SSL_R_TLSV1_ALERT_INSUFFICIENT_SECURITY          /* 1071 */
            || n == SSL_R_TLSV1_ALERT_INTERNAL_ERROR                 /* 1080 */
            || n == SSL_R_TLSV1_ALERT_USER_CANCELLED                 /* 1090 */
            || n == SSL_R_TLSV1_ALERT_NO_RENEGOTIATION               /* 1100 */
#endif
            )
        {
            switch (c->log_error) {

            case NGX_ERROR_IGNORE_ECONNRESET:
            case NGX_ERROR_INFO:
                level = NGX_LOG_INFO;
                break;

            case NGX_ERROR_ERR:
                level = NGX_LOG_ERR;
                break;

            default:
                break;
            }
        }
    }

    ngx_ssl_error(level, c->log, err, text);
}


static void
ngx_ssl_clear_errorex(ngx_log_t *log)
{
    while (ERR_peek_error()) {
        ngx_ssl_error(NGX_LOG_ALERT, log, 0, "ignoring stale global SSL error");
    }

    ERR_clear_error();
}