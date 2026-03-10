
--[[
-- -----------------------------------------------------------------------------
--  Brief       : 能力系统-属性集
--  File        : AttrSet.lua
--  Author      : zhengyanshuai
--  Date        : Sun Jan 18 2026 13:41:39 GMT+0800 (中国标准时间)
--  Description : 属性存储, 属性计算
--  License     : MIT License
-- -----------------------------------------------------------------------------
--  Copyright (c) 2026 zhengyanshuai
-- -----------------------------------------------------------------------------
--]]

local Class3 = require("Core/Class/Class3")
local AttrDef = require("System/Ability/Attr/AttrDef")
local log = require("Core/Log/log")

---@class AttrSetClass
---@field protected _Attributes table<number, number>
---@field protected _Dirty table<number, boolean> 后面用位运算
---@field protected _Modifiers AttrModifierClass[]
---@field protected _Manager AttrManager
local AttrSetClass = Class3.Class("AttrSetClass")

---@public
---@param InManager AttrManager
function AttrSetClass:Ctor(InManager, InAttributes)
    self._Manager = InManager
    self._Attributes = InAttributes
    self._Dirty = {}
    self._Modifiers = {}

    for id, _ in pairs(AttrDef.RefIdToKey) do
        self._Dirty[id] = true
    end
end

---@public
---@param InAttrKey number|string
function AttrSetClass:GetAttrValue(InAttrKey)
    local id = AttrDef.ToId(InAttrKey)
    if self._Dirty[id] then
        self:_UpdateAttribute(id)
    end
    return self._Attributes[id]
end

---@public
---@param InModifier AttrModifierClass
function AttrSetClass:AddModifier(InModifier)
    local id = AttrDef.ToId(InModifier.ModAttrKey)
    self:AddDirty(id)
    if not self._Modifiers[id] then
        self._Modifiers[id] = {}
    end
    table.insert(self._Modifiers[id], InModifier)
end

---@public
---@param InModifier AttrModifierClass
function AttrSetClass:RemoveModifier(InModifier)
    local id = AttrDef.ToId(InModifier.ModAttrKey)
    local mods = self._Modifiers[id]
    if mods then
        for i = 1, #mods do
            if mods[i] == InModifier then
                table.remove(mods, i)
                break
            end
        end
    end
    self:AddDirty(id)
end

---@public
---@param InAttrKey number
function AttrSetClass:AddDirty(InAttrKey)
    local id = AttrDef.ToId(InAttrKey)
    self._Dirty[id] = true
    local deps = self._Manager:GetAttrDependents(id)
    if deps then
        for _, dep in ipairs(deps) do
            self:AddDirty(dep)
        end
    end
end

---@public
---@param InAttrKey number
function AttrSetClass:RemoveDirty(InAttrKey)
    local id = AttrDef.ToId(InAttrKey)
    self._Dirty[id] = false
end

---@public
---@param InAttrKey number
function AttrSetClass:IsDirty(InAttrKey)
    local id = AttrDef.ToId(InAttrKey)
    return self._Dirty[id]
end

---@protected
---@param InAttrId number
function AttrSetClass:_UpdateAttribute(InAttrId)
    local baseValue = 0

    local totalAdd = 0
    local mods = self._Modifiers[InAttrId]
    if mods then
        ---@param mod AttrModifierClass
        for _, mod in ipairs(mods) do
            totalAdd = totalAdd + mod.ModValue
        end
    end

    local formula = self._Manager:GetAttrFormula(InAttrId)
    baseValue = formula and formula(self:_GetFormulaProxy()) or 0

    self._Attributes[InAttrId] = baseValue + totalAdd
    self._Dirty[InAttrId] = false
end

---@protected
function AttrSetClass:_GetFormulaProxy()
    if not self._Proxy then
        self._Proxy = setmetatable({}, {
            __index = function(_, k)
                local value = self:GetAttrValue(k)
                return value
            end
        })
    end
    return self._Proxy
end

---@public
function AttrSetClass:PrintModifiers()
    local str = string.format("\nBuffs:")
    for id, modifiers in pairs(self._Modifiers) do
        for i = 1, #modifiers do
            local modi = modifiers[i] ---@type AttrModifierClass
            str = string.format("%s\nId=%i, Attr=%s, Op=%s, Value=%i", str, modi.ModId, AttrDef.ToKey(modi.ModAttrKey), modi.ModOp, modi.ModValue)
        end
    end
    log.dev(str)
end

return AttrSetClass
