
---
---@brief   委托, 事件, 消息
---@authot  zys
---@data    Sat Nov 01 2025 19:56:29 GMT+0800 (中国标准时间)
---

---@class msgbus
---@field _tbEvent table<string, table<any, msgbus_regitem>>
local msgbus = ikf.class.class 'msgbus' {
    create = function()end,
    mtrigger = function()end,
    mreg = function()end,
    munreg = function()end,
    mclear = function()end,
    ctor = function()end,
    _tbEvent = nil,
}

function msgbus:ctor()
    self._tbEvent = {}
end

---@public
---@return msgbus
function msgbus.create()
    local bus = ikf.class.new 'msgbus' () ---@as msgbus
    return bus
end

---@param name string
---@param ... any
function msgbus:mtrigger(name, ...)
    if not self._tbEvent[name] then
        return
    end
    for _, item in pairs(self._tbEvent[name]) do
        item.fnCB(item.fnObj, ...)
    end
end

---@public
---@param name string
---@param obj any
---@param fn fun(...)
function msgbus:mreg(name, obj, fn)
    if not self._tbEvent[name] then
        self._tbEvent[name] = {}
    end

    ---@class msgbus_regitem
    local item = {
        fnCB = fn,
        fnObj = obj,
    }
    self._tbEvent[name][obj] = item
end

---@public
---@param name string
---@param obj any
function msgbus:munreg(name, obj)
    if not self._tbEvent[name] then
        return
    end
    self._tbEvent[name][obj] = nil
end

---@public
---@param name string
function msgbus:mclear(name)
    self._tbEvent[name] = nil
end

return msgbus