local _M = {}

-- entity state
_M.EntityState = {
    -- The entity is not being tracked by the context.
    Detached = 0,

    -- The entity is being tracked by the context and exists in the database. Its property
    --     values have not changed from the values in the database.
    Unchanged = 1,

    -- The entity is being tracked by the context and exists in the database. It has
    --     been marked for deletion from the database.
    Deleted = 2,

    -- The entity is being tracked by the context and exists in the database. Some or
    --     all of its property values have been modified.
    Modified = 3,

    -- The entity is being tracked by the context but does not yet exist in the database.
    Added = 4,
}

-- field type
_M.PROTOBUF_FIELD_TYPE = {
    -- 0 is reserved for errors.
    -- Order is weird for historical reasons.
    TYPE_DOUBLE         = 1,
    TYPE_FLOAT          = 2,

    -- Not ZigZag encoded.  Negative numbers take 10 bytes.  Use TYPE_SINT64 if
    --     negative values are likely.
    TYPE_INT64          = 3,
    TYPE_UINT64         = 4,
    
    -- Not ZigZag encoded.  Negative numbers take 10 bytes.  Use TYPE_SINT32 if
    --     negative values are likely.
    TYPE_INT32          = 5,
    TYPE_FIXED64        = 6,
    TYPE_FIXED32        = 7,
    TYPE_BOOL           = 8,
    TYPE_STRING         = 9,
    
    -- Tag-delimited aggregate.
    -- Group type is deprecated and not supported in proto3. However, Proto3
    --     implementations should still be able to parse the group wire format and
    --     treat group fields as unknown fields.
    TYPE_GROUP          = 10,
    TYPE_MESSAGE        = 11,  -- Length-delimited aggregate.

    -- New in version 2.
    TYPE_BYTES          = 12,
    TYPE_UINT32         = 13,
    TYPE_ENUM           = 14,
    TYPE_SFIXED32       = 15,
    TYPE_SFIXED64       = 16,
    TYPE_SINT32         = 17,  -- Uses ZigZag encoding.
    TYPE_SINT64         = 18,  -- Uses ZigZag encoding.
}

return _M