
--[[
-- -----------------------------------------------------------------------------
--  Brief       : Delegate
--  File        : Delegate.lua
--  Author      : zhengyanshuai
--  Date        : Mon Apr 06 2026 22:17:00 GMT+0800 (中国标准时间)
--  Description : 委托
--  License     : MIT License
-- -----------------------------------------------------------------------------
--  Copyright (c) 2026 zhengyanshuai
-- -----------------------------------------------------------------------------
--]]

local Class3 = require("Core/Class/Class3")
local make_weak = _G.make_weak

---@class Delegate
---@field tbCallback {Obj:any, Fn:fun(any, ...)}[]
local Delegate = Class3.Class("Delegate")

function Delegate:ctor()
    self.tbCallback = {}
end

---@public
function Delegate:Add(InObj, InFn)
    if not InObj or not InFn then
        return
    end
    table.insert(self.tbCallback, make_weak({Obj = InObj, Fn = InFn}))
end

---@public
function Delegate:Remove(InObj, InFn)
    for i, ele in pairs(self.tbCallback) do
        if ele.Obj == InObj and ele.Fn == InFn then
            table.remove(self.tbCallback, i)
            break
        end
    end
end

---@public
function Delegate:RemoveObj(InObj)
    for i = #self.tbCallback, 1, -1 do
        local ele = self.tbCallback[i]
        if ele.Obj == InObj then
            table.remove(self.tbCallback, i)
        end
    end
end

---@public
function Delegate:Clear()
    self.tbCallback = {}
end

---@public
function Delegate:Broadcast(...)
    for _, ele in pairs(self.tbCallback) do
        ele.Fn(ele.Obj, ...)
    end
end

return Delegate