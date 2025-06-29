
---
---@brief   双容器优化
---@author  zys
---@data    Sat Jun 28 2025 17:46:41 GMT+0800 (中国标准时间)
---

---@class duplex_item<K, V>
---@field _key K
---@field _value V
---@field _valid boolean

---@class duplex<K, V>
---@field _mapContainer table<K, duplex_item<K, V>>
---@field _arrContainer duplex_item<K,V>[]
---@field _count number
---@generic K, V
local duplex = class.class 'duplex' {
--[[public]]
    create = function()end,
    dinsert = function()end,
    dfind = function()end,
    dremove = function()end,
    dclear = function()end,
    dlength = function()end,
    diter = function()end,
--[[private]]
    ctor = function()end,
    _mapContainer = nil,
    _arrContainer = nil,
    _count = 0
}
---@public
---@return duplex<K, V>
function duplex.create(...)
    return class.new'duplex'(...)
end
---@private
function duplex:ctor()
    self._mapContainer = {}
    self._arrContainer = {}
    self._count = 0
end
---@public
---@param key K
---@param value V
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
---@public
---@param key K
function duplex:dfind(key)
    local item = self._mapContainer[key] ---@type duplex_item
    return item and item._valid and item._value or nil
end
---@public
---@param key K
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
---@public
function duplex:dclear()
    self._mapContainer = {}
    self._arrContainer = {}
    self._count = 0
end
---@public
function duplex:dlength()
    return self._count
end
---@public
---@return fun(t:table, i:number):(number, K, V)
function duplex:diter()
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