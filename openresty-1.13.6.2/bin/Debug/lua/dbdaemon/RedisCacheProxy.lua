-- Localize
local cwd = (...):gsub('%.[^%.]+$', '') .. "."

local _M = {
    _tasks = false,
}

local mt = { __index = _M }

local function _createIdHash(moduleName, mainId, subid)
    subid = subid or "1"
    return moduleName .. ":" .. mainId .. ":" .. subid .. ":H"
end

local function _createIdHashOfDirtyKeys(moduleName, mainId, subid)
    subid = subid or "1"
    return moduleName .. ":" .. mainId .. ":" .. subid .. ":D_H"
end

function _M.new(self, moduleName, mainId, subid)
    
    return setmetatable({
        _moduleName = moduleName,
        _mainId = mainId,
        _subid = subid,
        _idHash = _createIdHash(moduleName, mainId, subid),
        _iIdHashOfDirtyKeys = _createIdHashOfDirtyKeys(moduleName, mainId, subid),
    }, mt)
end

return _M