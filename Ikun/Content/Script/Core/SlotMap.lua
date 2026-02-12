
--[[
-- -----------------------------------------------------------------------------
--  Brief       : SlotMap
--  File        : SlotMap.lua
--  Author      : zhengyanshuai
--  Date        : Wed Feb 11 2026 22:29:20 GMT+0800 (中国标准时间)
--  Description : SlotMap
--  License     : MIT License
-- -----------------------------------------------------------------------------
--  Copyright (c) 2026 zhengyanshuai
-- -----------------------------------------------------------------------------
--]]

local Class3 = require('Core/Class/Class3')

---@class SlotMapClass
---@field protected _Values table<number, any>
---@field protected _Generations table<number, number>
---@field protected _Free table<number, number>
---@field protected _Count number
local SlotMapClass = Class3.Class('SlotMapClass')

function SlotMapClass:Ctor()
    self._Values = {}
    self._Generations = {}
    self._Free = {}
    self._Count = 0
end

function SlotMapClass:Insert(InValue)
    local index = table.remove(self._Free)
    if not index then
        index = #self._Values + 1
        self._Generations[index] = self._Generations[index] or 1
    end
    self._Values[index] = InValue
    self._Count = self._Count + 1
    return { Index = index, Gen = self._Generations[index] }
end

function SlotMapClass:Get(InHandle)
    local i = InHandle and InHandle.Index
    local g = InHandle and InHandle.Gen
    if not i or not g then
        return nil
    end
    if self._Generations[i] ~= g then
        return nil
    end
    return self._Values[i]
end

function SlotMapClass:Set(InHandle, InValue)
    local i = InHandle and InHandle.Index
    local g = InHandle and InHandle.Gen
    if not i or not g then
        return false
    end
    if self._Generations[i] ~= g then
        return false
    end
    self._Values[i] = InValue
    return true
end

function SlotMapClass:Remove(InHandle)
    local i = InHandle and InHandle.Index
    local g = InHandle and InHandle.Gen
    if not i or not g then
        return nil
    end
    if self._Generations[i] ~= g then
        return nil
    end
    local v = self._Values[i]
    self._Values[i] = nil
    self._Generations[i] = g + 1
    table.insert(self._Free, i)
    self._Count = self._Count - 1
    return v
end

function SlotMapClass:IsValid(InHandle)
    local i = InHandle and InHandle.Index
    local g = InHandle and InHandle.Gen
    if not i or not g then
        return false
    end
    return self._Generations[i] == g and self._Values[i] ~= nil
end

function SlotMapClass:Size()
    return self._Count
end

function SlotMapClass:Items()
    local res = {}
    for i = 1, #self._Generations do
        local v = self._Values[i]
        if v ~= nil then
            res[#res + 1] = { Handle = { Index = i, Gen = self._Generations[i] }, Value = v }
        end
    end
    return res
end

return SlotMapClass
