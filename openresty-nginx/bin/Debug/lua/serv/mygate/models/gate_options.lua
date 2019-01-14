_M = {
    mysql = {
        host = "127.0.0.1",
        user = "root",
        password = "123123",
        database = "sandbox"
    },
    _gate_db_options = false
}

local db_options = require("db.mysql_options")

function _M.getOptions()
    -- create options if not cached yet
    if not _M._gate_db_options then
        _M._gate_db_options = db_options.new(_M.mysql)
    end
    return _M._gate_db_options
end

return _M
