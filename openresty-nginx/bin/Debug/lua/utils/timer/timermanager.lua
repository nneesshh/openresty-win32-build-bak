local cwd = (...):gsub("%.[^%.]+$", "") .. "."
local tw = require(cwd .. "timerwheel")

local _M = {
    _wheel = tw.new(),

    _tickerMap = {},
    _slicerMap = {}
}

function _M.now()
    return _M._wheel:now()
end

function _M.advance()
    return _M._wheel:step()
end

function _M.update(dt)
    return _M._wheel:update(dt)
end

function _M.createTimeTicker(name)
    local ticker
    local tickerCls = require(cwd .. "timeticker")
    ticker = tickerCls.new(name)
    _M._tickerMap[ticker.name] = ticker
    return ticker
end

function _M.createTimeSlicer(name, format)
    local slicer
    local slicerCls = require(cwd .. "timeslicer")
    slicer = slicerCls.new(name, format)
    _M._slicerMap[slicer.name] = slicer
    return slicer
end

return _M
