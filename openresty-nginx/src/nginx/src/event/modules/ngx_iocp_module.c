
/*
 * Copyright (C) Igor Sysoev
 * Copyright (C) Nginx, Inc.
 */


#include <ngx_config.h>
#include <ngx_core.h>
#include <ngx_event.h>
#include <ngx_iocp_module.h>


void
output_debug_string(ngx_connection_t *c, const char *format, ...)
{
    va_list args;

#define OUTPUT_DEBUG_BUFSIZE 32768
    static char buf[OUTPUT_DEBUG_BUFSIZE];
    char *p;

    p = buf;

    va_start(args, format);
    p += _vsnprintf(p, OUTPUT_DEBUG_BUFSIZE - strlen(buf) - 1, format, args);
    va_end(args);

    while (p > buf && isspace(p[-1]))
    {
        *--p = '\0';
    }

    if (NULL == c->log->data) {
        c->log->data = c;
    }
    ngx_log_error(NGX_LOG_INFO, c->log, 0, "________________________________\n%s\n", buf);
}


static ngx_int_t ngx_iocp_init(ngx_cycle_t *cycle, ngx_msec_t timer);
static ngx_thread_value_t __stdcall ngx_iocp_timer(void *data);
static void ngx_iocp_done(ngx_cycle_t *cycle);
static ngx_int_t ngx_iocp_add_event(ngx_event_t *ev, ngx_int_t event,
    ngx_uint_t key);
static ngx_int_t ngx_iocp_del_event(ngx_event_t *ev, ngx_int_t event,
    ngx_uint_t flags);
static ngx_int_t ngx_iocp_del_connection(ngx_connection_t *c, ngx_uint_t flags);
static ngx_int_t ngx_iocp_process_events(ngx_cycle_t *cycle, ngx_msec_t timer,
    ngx_uint_t flags);
static void *ngx_iocp_create_conf(ngx_cycle_t *cycle);
static char *ngx_iocp_init_conf(ngx_cycle_t *cycle, void *conf);


static ngx_str_t      iocp_name = ngx_string("iocp");

static ngx_command_t  ngx_iocp_commands[] = {

    { ngx_string("iocp_threads"),
      NGX_EVENT_CONF|NGX_CONF_TAKE1,
      ngx_conf_set_num_slot,
      0,
      offsetof(ngx_iocp_conf_t, threads),
      NULL },

    { ngx_string("post_acceptex"),
      NGX_EVENT_CONF|NGX_CONF_TAKE1,
      ngx_conf_set_num_slot,
      0,
      offsetof(ngx_iocp_conf_t, post_acceptex),
      NULL },

    { ngx_string("acceptex_read"),
      NGX_EVENT_CONF|NGX_CONF_FLAG,
      ngx_conf_set_flag_slot,
      0,
      offsetof(ngx_iocp_conf_t, acceptex_read),
      NULL },

      ngx_null_command
};


static ngx_event_module_t  ngx_iocp_module_ctx = {
    &iocp_name,
    ngx_iocp_create_conf,                  /* create configuration */
    ngx_iocp_init_conf,                    /* init configuration */

    {
        ngx_iocp_add_event,                /* add an event */
        ngx_iocp_del_event,                /* delete an event */
        NULL,                              /* enable an event */
        NULL,                              /* disable an event */
        NULL,                              /* add an connection */
        ngx_iocp_del_connection,           /* delete an connection */
        NULL,                              /* trigger a notify */
        ngx_iocp_process_events,           /* process the events */
        ngx_iocp_init,                     /* init the events */
        ngx_iocp_done                      /* done the events */
    }

};

ngx_module_t  ngx_iocp_module = {
    NGX_MODULE_V1,
    &ngx_iocp_module_ctx,                  /* module context */
    ngx_iocp_commands,                     /* module directives */
    NGX_EVENT_MODULE,                      /* module type */
    NULL,                                  /* init master */
    NULL,                                  /* init module */
    NULL,                                  /* init process */
    NULL,                                  /* init thread */
    NULL,                                  /* exit thread */
    NULL,                                  /* exit process */
    NULL,                                  /* exit master */
    NGX_MODULE_V1_PADDING
};


ngx_os_io_t ngx_iocp_io = {
    ngx_overlapped_wsarecv,
    NULL,
    ngx_udp_overlapped_wsarecv,
    ngx_overlapped_wsasend,
    NULL,
    NULL,
    ngx_overlapped_wsasend_chain,
    0
};


static HANDLE      iocp;
static ngx_tid_t   timer_thread;
static ngx_msec_t  msec;


static ngx_int_t
ngx_iocp_init(ngx_cycle_t *cycle, ngx_msec_t timer)
{
    ngx_iocp_conf_t  *cf;

    cf = ngx_event_get_conf(cycle->conf_ctx, ngx_iocp_module);

    if (iocp == NULL) {
        iocp = CreateIoCompletionPort(INVALID_HANDLE_VALUE, NULL, 0,
                                      cf->threads);
    }

    if (iocp == NULL) {
        ngx_log_error(NGX_LOG_ALERT, cycle->log, ngx_errno,
                      "CreateIoCompletionPort() failed");
        return NGX_ERROR;
    }

    ngx_io = ngx_iocp_io;

    ngx_event_actions = ngx_iocp_module_ctx.actions;

    ngx_event_flags = NGX_USE_IOCP_EVENT;

    if (timer == 0) {
        return NGX_OK;
    }

    /*
     * The waitable timer could not be used, because
     * GetQueuedCompletionStatus() does not set a thread to alertable state
     */

    if (timer_thread == NULL) {

        msec = timer;

        if (ngx_create_thread(&timer_thread, ngx_iocp_timer, &msec, cycle->log)
            != 0)
        {
            return NGX_ERROR;
        }
    }

    ngx_event_flags |= NGX_USE_TIMER_EVENT;

    return NGX_OK;
}


static ngx_thread_value_t __stdcall
ngx_iocp_timer(void *data)
{
    ngx_msec_t  timer = *(ngx_msec_t *) data;

    ngx_log_debug2(NGX_LOG_DEBUG_EVENT, ngx_cycle->log, 0,
                   "THREAD %p %p", &msec, data);

    for ( ;; ) {
        Sleep(timer);

        ngx_time_update();
#if 1
        ngx_log_debug0(NGX_LOG_DEBUG_EVENT, ngx_cycle->log, 0, "timer");
#endif
    }

#if defined(__WATCOMC__) || defined(__GNUC__)
    return 0;
#endif
}


static void
ngx_iocp_done(ngx_cycle_t *cycle)
{
    if (CloseHandle(iocp) == -1) {
        ngx_log_error(NGX_LOG_ALERT, cycle->log, ngx_errno,
                      "iocp CloseHandle() failed");
    }

    iocp = NULL;
}


static ngx_int_t
ngx_iocp_add_event(ngx_event_t *ev, ngx_int_t event, ngx_uint_t key)
{
    ngx_connection_t  *c;

    c = (ngx_connection_t *) ev->data;

    c->read->active = 1;
    c->write->active = 1;

    ngx_log_debug3(NGX_LOG_DEBUG_EVENT, ev->log, 0,
                   "iocp add: fd:%d k:%ui ov:%p", c->fd, key, &ev->evovlp);

    if (CreateIoCompletionPort((HANDLE) c->fd, iocp, key, 0) == NULL) {
        ngx_log_error(NGX_LOG_ALERT, c->log, ngx_errno,
                      "CreateIoCompletionPort() failed");
        return NGX_ERROR;
    }

    return NGX_OK;
}


static ngx_int_t
ngx_iocp_del_event(ngx_event_t *ev, ngx_int_t event, ngx_uint_t flags)
{
    /* cancel io pending event not work now, so just ignore this */
    return NGX_OK;
}


static ngx_int_t
ngx_iocp_del_connection(ngx_connection_t *c, ngx_uint_t flags)
{
#if 0
    if (flags & NGX_CLOSE_EVENT) {
        return NGX_OK;
    }

    if (CancelIo((HANDLE) c->fd) == 0) {
        ngx_log_error(NGX_LOG_ALERT, c->log, ngx_errno, "CancelIo() failed");
        return NGX_ERROR;
    }
#endif

    return NGX_OK;
}


static
ngx_int_t ngx_iocp_process_events(ngx_cycle_t *cycle, ngx_msec_t timer,
    ngx_uint_t flags)
{
#define OVLP_ENTRY_MAX 1024
    OVERLAPPED_ENTRY   overlappeds[OVLP_ENTRY_MAX] = { 0 };
    LPOVERLAPPED_ENTRY ovlp_entry;
    u_long             count;
    u_long             i;

    int                rc;
    u_int              key;
    u_long             bytes;
    ngx_err_t          err;
    ngx_msec_t         delta;
    ngx_event_t       *ev;
    ngx_event_ovlp_t  *evovlp;

//#if (NGX_DEBUG)
    ngx_connection_t  *c;
//#endif

    if (timer == NGX_TIMER_INFINITE) {
        timer = INFINITE;
    }

    ngx_log_debug1(NGX_LOG_DEBUG_EVENT, cycle->log, 0, "iocp timer: %M", timer);

    rc = ngx_getqueuedcompletionstatusex(
        iocp,
        overlappeds,
        OVLP_ENTRY_MAX,
        &count,
        (u_long)timer,
        FALSE);

    delta = ngx_current_msec;

    if (flags & NGX_UPDATE_TIME) {
        ngx_time_update();
    }

    /*ngx_log_debug4(NGX_LOG_DEBUG_EVENT, cycle->log, 0,
                   "iocp: %d b:%d k:%d ov:%p", rc, bytes, key, evovlp);*/

    if (timer != INFINITE) {
        delta = ngx_current_msec - delta;

        ngx_log_debug2(NGX_LOG_DEBUG_EVENT, cycle->log, 0,
                       "iocp timer: %M, delta: %M", timer, delta);
    }

    if (rc == 0) {
        err = ngx_socket_errno;

        if (err != WAIT_TIMEOUT) {
            ngx_log_error(NGX_LOG_ALERT, cycle->log, err,
                            "GetQueuedCompletionStatus() failed");

            return NGX_ERROR;
        }

        return NGX_OK;
    }
    else {

        for (i = 0; i < count; i++) {
            /* Package was dequeued, but see if it is not a empty package
            * meant only to wake us up.
            */
            if (overlappeds[i].lpOverlapped) {
                ovlp_entry = &overlappeds[i];
                key = ovlp_entry->lpCompletionKey;
                evovlp = (ngx_event_ovlp_t *)ovlp_entry->lpOverlapped;
                bytes = ovlp_entry->dwNumberOfBytesTransferred;

                if (evovlp) {

                    ngx_log_debug4(NGX_LOG_DEBUG_EVENT, cycle->log, 0,
                        "iocp: %d b:%d k:%d ov:%p", rc, bytes, key, evovlp);

                    ev = evovlp->event;

                    ngx_log_debug1(NGX_LOG_DEBUG_EVENT, cycle->log, 0, "iocp event:%p", ev);

//#if (NGX_DEBUG)
                    // connection
                    c = ev->data;

                    if (c && c->close && !ev->closed) {
                        output_debug_string(c, "xxxxxxxxxxxxxxxxxxxxxxxxxxxxx");
                    }

                    if (0 == ev->write && 0 == evovlp->recv_mem_lock_flag) {
                        output_debug_string(c, "yyyyyyyyyyyyyyyyyyyyyyyyyyyyy");
                    }
//#endif

                    /* ngx_get_connection() use "evovlp->recv_mem_lock_flag" to ensure that the memory posted to recv has already freed correctly */
                    evovlp->recv_mem_lock_flag = 0;

                    if (c && c->close) {
                        continue;
                    }

                    /* Skip events from a closed socket */
                    if (ev->closed
                        || (NGX_IOCP_ACCEPT != key && 1 == evovlp->acceptex_flag))
                    {
                        /* Event is already closed, or acceptex event is not ready yet, or write event is in disable state,
                           all events must be ignored except NGX_IOCP_ACCEPT. */
                        continue;
                    }

 #if (NGX_DEBUG)
                    // debug
                    {
                        if (NGX_IOCP_ACCEPT == key || NGX_IOCP_IO == key) {
                            if (0 == bytes) {
                                output_debug_string(c, "\nzero bytes found!!!! -- c(%d)fd(%d)destroyed(%d)_r(0x%08x)w(0x%08x)c(0x%08x) ... w(%d)key(%d) -- bytes(%d)\n",
                                    c->id, c->fd, c->destroyed, (uintptr_t)c->read, (uintptr_t)c->write, (uintptr_t)c, 
                                    ev->write, key,
                                    bytes);
                            }
                        }

                        if (0 == ev->write) {
                            output_debug_string(c, "\n[READ(%d)] c(%d)fd(%d)destroyed(%d)_r(0x%08x)w(0x%08x)c(0x%08x) ... w(%d)key(%d) -- with buffer(0x%08x)(%d)_bytes(%d)\n",
                                key,
                                c->id, c->fd, c->destroyed, (uintptr_t)c->read, (uintptr_t)c->write, (uintptr_t)c,
                                ev->write, key,
                                (uintptr_t)c->buffer_ref.last, (int)(c->buffer_ref.end - c->buffer_ref.last), bytes);
                        }
                        else {
                            output_debug_string(c, "\n[SEND(%d)] c(%d)fd(%d)destroyed(%d)_r(0x%08x)w(0x%08x)c(0x%08x) ... w(%d)key(%d) -- bytes(%d)\n",
                                key,
                                c->id, c->fd, c->destroyed, (uintptr_t)c->read, (uintptr_t)c->write, (uintptr_t)c,
                                ev->write, key,
                                bytes);
                        }

                        if (0 == ev->write && 0 != ev->ready) {
                            output_debug_string(c, "\nread event crashed(invalid ready flag)!!!! -- c(%d)fd(%d)destroyed(%d)_r(0x%08x)w(0x%08x)c(0x%08x) ... w(%d)key(%d) -- bytes(%d)\n",
                                c->id, c->fd, c->destroyed, (uintptr_t)c->read, (uintptr_t)c->write, (uintptr_t)c,
                                ev->write, key,
                                bytes);
                        }
                    }
#endif

                      switch (key) {

                    case NGX_IOCP_ACCEPT:
                        /* lpCompletionKey is the key of listen iocp port, but ev->evovlp is ovlp of normal iocp port */
                        evovlp->acceptex_flag = 0;
                        if (bytes) {
                            ev->ready = 1;
                        }
                        break;

                    case NGX_IOCP_IO:
                        /* normal iocp port */
                        ev->complete = 1;
                        ev->ready = 1;
                        break;

                    case NGX_IOCP_CONNECT:
                        /* normal iocp port */
                        if (bytes) {
                            ev->complete = 1;
                        }
                        ev->ready = 1;
                        break;
                    }

                    ev->available = bytes;

#if (NGX_DEBUG)
                    // debug
                    if (NGX_IOCP_ACCEPT == key || NGX_IOCP_IO == key) {
                        if (0 == ev->write && bytes > 0) {
                            char data[8192] = { 0 };
                            size_t len = ngx_min(sizeof(data) - 1, bytes);
                            char *p;

                            memcpy(data, c->buffer_ref.pos, len);
                            output_debug_string(c, "\n\t>>>> server read begin\n");

                            if (c->buffer) {
                                output_debug_string(c, "\t     c->buffer(0x%08x) -- start(0x%08x)end(0x%08x)size(%d), pos(0x%08x)last(0x%08x)size(%d)\n",
                                    (uintptr_t)c->buffer,
                                    (uintptr_t)c->buffer->start, (uintptr_t)c->buffer->end, (int)(c->buffer->end - c->buffer->start),
                                    (uintptr_t)c->buffer->pos, (uintptr_t)c->buffer->last, (int)(c->buffer->last - c->buffer->pos));
                            }
                            output_debug_string(c, "\t     c->buffer_ref(0x%08x) -- start(0x%08x)end(0x%08x)size(%d), pos(0x%08x)last(0x%08x)size(%d)\n",
                                (uintptr_t)&c->buffer_ref,
                                (uintptr_t)c->buffer_ref.start, (uintptr_t)c->buffer_ref.end, (int)(c->buffer_ref.end - c->buffer_ref.start),
                                (uintptr_t)c->buffer_ref.pos, (uintptr_t)c->buffer_ref.last, (int)(c->buffer_ref.last - c->buffer_ref.pos));

                            output_debug_string(c, "\t     c(%d)fd(%d)destroyed(%d)\n\t     key(%d) bytes(%d/%d) -- data: \n\n%s\n",
                                c->id, c->fd, c->destroyed,
                                key, (int)len, bytes,
                                data);
                            p = ngx_hex_dump((u_char *)data, (u_char *)c->buffer_ref.pos, len);
                            *p = '\0';
                            output_debug_string(c, "\tdata_hex: \n\n%s\n", data);
                            output_debug_string(c, "\n\t<<<< server read end\n\n");
                        }
                    }
#endif

                    ngx_log_debug1(NGX_LOG_DEBUG_EVENT, cycle->log, 0,
                                   "iocp event handler: %p", ev->handler);

                    ev->handler(ev);
                }
            }
        }
    }

    return NGX_OK;
}


static void *
ngx_iocp_create_conf(ngx_cycle_t *cycle)
{
    ngx_iocp_conf_t  *cf;

    cf = ngx_palloc(cycle->pool, sizeof(ngx_iocp_conf_t));
    if (cf == NULL) {
        return NGX_CONF_ERROR;
    }

    cf->threads = NGX_CONF_UNSET;
    cf->post_acceptex = NGX_CONF_UNSET;
    cf->acceptex_read = NGX_CONF_UNSET;

    return cf;
}


static char *
ngx_iocp_init_conf(ngx_cycle_t *cycle, void *conf)
{
    ngx_iocp_conf_t *cf = conf;

    ngx_conf_init_value(cf->threads, 0);
    ngx_conf_init_value(cf->post_acceptex, 10);
    ngx_conf_init_value(cf->acceptex_read, 1);

    return NGX_CONF_OK;
}

ngx_int_t
ngx_iocp_create_port(ngx_event_t *ev, ngx_uint_t key)
{
    ngx_connection_t  *c;

    c = (ngx_connection_t *)ev->data;

    c->read->active = 1;
    c->write->active = 1;

    ngx_log_debug3(NGX_LOG_DEBUG_EVENT, ev->log, 0,
                   "iocp add: fd:%d k:%ui ov:%p", c->fd, key, &ev->evovlp);

    if (CreateIoCompletionPort((HANDLE)c->fd, iocp, key, 0) == NULL) {
        ngx_log_error(NGX_LOG_ALERT, c->log, ngx_errno,
                      "CreateIoCompletionPort() failed");
        return NGX_ERROR;
    }

    return NGX_OK;
}