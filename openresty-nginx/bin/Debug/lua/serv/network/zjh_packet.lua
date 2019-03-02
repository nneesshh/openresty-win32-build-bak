local ffi = require "ffi"

local sizeof = ffi.sizeof
local offsetof = ffi.offsetof
local C = ffi.C

local tbl_insert = table.insert
local str_sub = string.sub

local PER_FRAME_PAGE_SIZE_MAX = 4096

ffi.cdef [[

#pragma pack(1)

typedef struct
{
	char			key[8];
	unsigned int	size;
	unsigned int	sessionId;
	unsigned short	msgId;
	unsigned char	version;
	char			reserve[1];
} MSG_HEADER;

#pragma pack()

typedef struct memory_stream_s
{
	char* buffer;
	char* cursor;
	int size;
} memory_stream_t;

memory_stream_t * create_memory_stream(char* buffer, int size);
void              destroy_memory_stream(memory_stream_t *stream);

void              memory_stream_seek(memory_stream_t *stream, int pos);
void              memory_stream_skip(memory_stream_t *stream, int len);
int               memory_stream_get_pos(memory_stream_t *stream);
int               memory_stream_get_free_size(memory_stream_t *stream);

int8_t            memory_stream_read_byte(memory_stream_t *stream);
int16_t           memory_stream_read_int16(memory_stream_t *stream);
int32_t           memory_stream_read_int32(memory_stream_t *stream);
int64_t           memory_stream_read_int64(memory_stream_t *stream);
char *            memory_stream_read_string(memory_stream_t *stream, int16_t *outlen);

void              memory_stream_read_buffer(memory_stream_t *stream, unsigned char *dest, int len);

void              memory_stream_write_byte(memory_stream_t *stream, unsigned char d);
void              memory_stream_write_int16(memory_stream_t *stream, int16_t d2);
void              memory_stream_write_int32(memory_stream_t *stream, int32_t d4);
void              memory_stream_write_int64(memory_stream_t *stream, int64_t d8);
void              memory_stream_write_string(memory_stream_t *stream, const char* str, int16_t len);

void              memory_stream_write_buffer(memory_stream_t *stream, unsigned char *src, int len);

]]

local frame_leading_t = ffi.typeof("MSG_HEADER")
local SIZE_OF_FRAME_PAGE_LEADING = sizeof(frame_leading_t, 0)
local lcutil = ffi.load(ffi.os == "Windows" and "lcutil" or "lcutil")

----
local _P = {}

--
function _P:read(s)
    -- frame leading
    local fldata, flerr = s:receive(SIZE_OF_FRAME_PAGE_LEADING)
    if not fldata then
        return nil, "failed to read frame leading -- " .. flerr
    end

    ffi.copy(self.frm_l_r, fldata, #fldata)

    while true do
        --
        local remain_data_size = self.frm_l_r.size

        -- packet data
        local pddata, pderr = s:receive(remain_data_size)
        if not pddata then
            return nil, "failed to read packet data" .. pderr
        end

        tbl_insert(self.pkt_r.data, pddata)
        self.pkt_r.data_size = self.pkt_r.data_size + #pddata

        --
        break
    end

    return self.pkt_r
end

--
function _P:write(s, sessionId, msgId, msgdata)
    local sent = 0
    local remain_size = #msgdata
    local send_size_max
    local send_size
    local pkt_w

    -- first page
    send_size_max = PER_FRAME_PAGE_SIZE_MAX - SIZE_OF_FRAME_PAGE_LEADING

    pkt_w = {}
    send_size = (remain_size <= send_size_max) and remain_size or send_size_max
    remain_size = remain_size - send_size

    -- not overflow
    if remain_size > 0 then
        error("packet size overflow!!!")
    else
        -- frame leading init
        self.frm_l_w.size = remain_size
        self.frm_l_w.sessionId = sessionId
        self.frm_l_w.msgId = msgId

        -- header
        tbl_insert(pkt_w, ffi.string(self.frm_l_w, SIZE_OF_FRAME_PAGE_LEADING))
        
        -- body
        tbl_insert(pkt_w, str_sub(msgdata, 1, send_size))

        s:send(pkt_w)
        sent = sent + send_size
    end

    return sent
end

-- packet type 1: outer packet
_P.new = function()

    local function get_sessionid(self)
        return self.frm_l_r.sessionId
    end

    local function get_msgid(self)
        return self.frm_l_r.msgId
    end

    local function lcutil(self)
        return lcutil
    end

    local self = {
        -- read
        frm_l_r = frame_leading_t(),
        pkt_r = {
            sn = 0,
            name = "",
            data_size = 0,
            data = {}
        },
        -- write
        frm_l_w = frame_leading_t(),
        --
        getSessionId = get_sessionid,
        getMsgId = get_msgid,
        lcutil = lcutil
    }

    return setmetatable(
        self,
        {
            __index = _P
        }
    )
end

return _P
