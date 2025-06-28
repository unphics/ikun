
---
---@brief   双容器优化
---@author  zys
---@data    Sat Jun 28 2025 17:46:41 GMT+0800 (中国标准时间)
---

---@class duplex_item
---@field _key any
---@field _value any
---@field _valid boolean

---@class duplex
---@field _mapContainer table<any, duplex_item>
---@field _arrContainer duplex_item[]
---@field _count number
local duplex = class.class 'duplex' {
--[[public]]
    ctor = function()end,
    create = function()end,
--[[private]]
    _mapContainer = nil,
    _arrContainer = nil,
    _count = 0
}

---@return duplex
function duplex.create(...)
    return class.new'duplex'(...)
end

function duplex:ctor()
    self._mapContainer = {}
    self._arrContainer = {}
    self._count = 0
end

function duplex:dinsert(key, value)
    assert(key ~= nil, "duplex:dinsert() key cannot be nil")
    if self._mapContainer[key] then
        error('duplicate key:'..tostring(key))
    end
    local duplex_item = {
        _key = key,
        _value = value,
        _valid = true,
    }
    table.insert(self._arrContainer, duplex_item)
    self._mapContainer[key] = duplex_item
    self._count = self._count + 1
end

function duplex:dfind(key)
    local item = self._mapContainer[key] ---@type duplex_item
    return item and item._valid and item._value or nil
end

---@return boolean
function duplex:dremove(key)
    local item = self._mapContainer[key]
    if not item or not item._valid then
        return false
    end
    item._valid = false
    self._mapContainer[key] = nil
    self._count = self._count - 1
    return true
end

function duplex:dclear()
    self._mapContainer = {}
    self._arrContainer = {}
    self._count = 0
end

function duplex:dlength()
    return self._count
end

function duplex:iter()
    return function(arr, i)
        i = i + 1
        while i <= #arr do
            local item = arr[i] ---@type duplex_item
            if item._valid then
                return i, item._key, item._value
            end
            i = i + 1
        end
    end, self._arrContainer, 0
end

return duplex