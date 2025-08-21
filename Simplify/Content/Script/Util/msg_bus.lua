
---
---@brief   委托, 事件, 消息
---

---@class msgbus
---@field tbEvent table<string, table<any, msgbus_regitem>>
local msgbus = class.class 'msgbus' {
--[[public]]
    create = function()end,
    mtrigger = function()end,
    mreg = function()end,
    munreg = function()end,
    mclear = function()end,
--[[private]]
    ctor = function()end,
    tbEvent = nil,
}

function msgbus:ctor()
    self.tbEvent = {}
end

---@public
---@return msgbus
function msgbus.create()
    local bus = class.new 'msgbus' () ---@type msgbus
    return bus
end

---@param name string
---@param ... any
function msgbus:mtrigger(name, ...)
    if not self.tbEvent[name] then
        return
    end
    for _, item in pairs(self.tbEvent[name]) do
        item.fnCB(item.fnObj, ...)
    end
end

---@public
---@param name string
---@param obj any
---@param fn fun(...)
function msgbus:mreg(name, obj, fn)
    if not self.tbEvent[name] then
        self.tbEvent[name] = {}
    end

    ---@class msgbus_regitem
    local item = {
        fnCB = fn,
        fnObj = obj,
    }
    self.tbEvent[name][obj] = item
end

---@public
---@param name string
---@param obj any
function msgbus:munreg(name, obj)
    if not self.tbEvent[name] then
        return
    end
    self.tbEvent[name][obj] = nil
end

---@public
---@param name string
function msgbus:mclear(name)
    self.tbEvent[name] = nil
end

-- log.debug('msgbus测试 *******************')
-- local a = {}
-- function a:fn(a)
--     log.debug('msgbus测试 a:fn()',a)
-- end

-- local b = {}
-- function b:fn(a)
--     log.debug('msgbus测试 b:fn()',a)
-- end

-- local c = {}
-- function c:fn(a)
--     log.debug('msgbus测试 c:fn()',a)
-- end

-- local m = msgbus.create()
-- m:mreg('e1', a, a.fn)
-- m:mreg('e1', b, b.fn)
-- m:mreg('e1', c, c.fn)
-- m:mtrigger('e1', 'e1')

-- log.debug('msgbus测试 *******************')
-- m:mreg('e2', a, a.fn)
-- m:mreg('e2', b, b.fn)
-- m:mtrigger('e2', 'e2')

-- log.debug('msgbus测试 *******************')
-- m:munreg('e1', a)
-- m:mtrigger('e1', 'e1')

-- log.debug('msgbus测试 *******************')

return msgbus