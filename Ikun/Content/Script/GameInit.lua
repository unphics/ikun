
---
---@brief   服务端初始化顺序管理
---@author  zys
---@data    Tue Sep 23 2025 11:13:55 GMT+0800 (中国标准时间)
---

---@class gameinit
---@field ring ring
---@field _initring table
local gameinit = {}

---@enum ring
gameinit.ring = {
    zero    = 'zero',   -- 零环初始化, 
    one     = 'one',    -- 一环初始化, 全局无状态Lib, 无状态Uitl等无状态模块初始化
    two     = 'two',    -- 二环初始化, 全局模块管理, 重要游戏内容模块初始化
    three   = 'three',  -- 
    four    = 'four',   -- 
    five    = 'five',   -- 
    six     = 'six',    -- 
    seven   = 'seven',  -- 
    eight   = 'eight',  -- 
    nine    = 'nine',   -- 
    ten     = 'ten',    -- 
}

gameinit._initring = {}

for _, enum in pairs(gameinit.ring) do
    gameinit._initring[enum] = {}
end

---@public
---@param enum ring
---@param callback fun(table)
gameinit.registerinit = function(enum, obj, callback)
    local delegate = gameinit._initring[enum]
    if delegate._inited then
        callback(obj)
        return
    end
    table.insert(delegate, {obj = obj, callback = callback})
end

---@public
---@param enum ring
gameinit.triggerinit = function(enum)
    gameinit._initring[enum]._inited = true
    for _, tb in ipairs(gameinit._initring[enum]) do
        tb.callback(tb.obj)
    end
end

return gameinit