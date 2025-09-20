
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
function duplex.create()
    return class.new'duplex'()
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
    local item = self._mapContainer[key]
    if item then
        if item._valid then
            error('duplicate key: ' .. tostring(key))
        else
            -- 复用删除项
            item._value = value
            item._valid = true
            self._mapContainer[key] = item
            self._count = self._count + 1
            self:_autoCompact()
            return
        end
    end
    local newItem = {
        _key = key,
        _value = value,
        _valid = true,
    }
    table.insert(self._arrContainer, newItem)
    self._mapContainer[key] = newItem
    self._count = self._count + 1
    self:_autoCompact()
end
---@public
---@param key K
---@return V
function duplex:dfind(key)
    local item = self._mapContainer[key] ---@type duplex_item
    return item and item._valid and item._value or nil
end
---@public
---@param idx number
---@return V
function duplex:dget(idx)
    assert(idx > 0, 'duplex:dget')
    local count = 0
    for _, item in ipairs(self._arrContainer) do
        if item._valid then
            count = count + 1
            if count == idx then
                return item._value
            end
        end
    end
    return nil
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
    self:_autoCompact()
    return true
end
---@public
---@param fnCompare fun(a: V, b: V):boolean
function duplex:dsort(fnCompare)
    if not fnCompare then
        return
    end
    self:dcompact()
    table.sort(self._arrContainer, function(a, b)
        return fnCompare(a._value, b._value)
    end)
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

--- 手动压缩数组
function duplex:dcompact()
    local newArr = {}
    for _, item in ipairs(self._arrContainer) do
        if item._valid then
            table.insert(newArr, item)
        else
            self._mapContainer[item._key] = nil
        end
    end
    self._arrContainer = newArr
end

--- 自动压缩条件：当数组中无效项占一半以上时压缩
function duplex:_autoCompact()
    if #self._arrContainer >= self._count * 2 then
        self:dcompact()
    end
end

return duplex