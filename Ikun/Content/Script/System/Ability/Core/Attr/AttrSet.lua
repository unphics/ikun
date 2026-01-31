
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

local Class3 = require('Core/Class/Class3')
local Modifier = require('System/Ability/Core/Attr/Modifier')
local AttrDef = require("System/Ability/Core/Attr/AttrDef")
local ModOpDef = require("System/Ability/Core/Attr/ModOpDef")

---@class AttrSetClass
---@field protected _Attributes table<number, number>
---@field protected _Dirty table<number, boolean> 后面用位运算
---@field protected _Modifiers ModifierClass[]
---@field protected _Manager AttrManager
local AttrSetClass = Class3.Class('AttrSetClass')

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

---@public [Get] [Attribute]
---@param InAttrKey number|string
function AttrSetClass:GetAttrValue(InAttrKey)
    local id = AttrDef.ToId(InAttrKey)
    if self._Dirty[id] then
        self:_UpdateAttribute(id)
    end
    return self._Attributes[id]
end

---@public [Add] [Modifier]
---@param InModifier ModifierClass
function AttrSetClass:AddModifier(InModifier)
    local id = AttrDef.ToId(InModifier.AttrKey)
    self:AddDirty(id)
    if not self._Modifiers[id] then
        self._Modifiers[id] = {}
    end
    table.insert(self._Modifiers[id], InModifier)
end

---@public [Remove] [Modifier]
---@param InModifier ModifierClass
function AttrSetClass:RemoveModifier(InModifier)
    local id = AttrDef.ToId(InModifier.AttrKey)
    local mods = self._Modifiers[id]
    for i = 1, #mods do
        if mods[i] == InModifier then
            table.remove(mods, i)
            break
        end
    end
    self:AddDirty(id)
end

---@public [Dirty]
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

---@public [Dirty]
---@param InAttrKey number
function AttrSetClass:RemoveDirty(InAttrKey)
    local id = AttrDef.ToId(InAttrKey)
    self._Dirty[id] = false
end

---@public [Dirty]
---@param InAttrKey number
function AttrSetClass:IsDirty(InAttrKey)
    local id = AttrDef.ToId(InAttrKey)
    return self._Dirty[id]
end

---@protected
---@param InAttrId number
function AttrSetClass:_UpdateAttribute(InAttrId)
    local attr = AttrDef.ToKey(InAttrId)
    local formula = self._Manager:GetAttrFormula(InAttrId)
    local baseValue = 0
    if formula then
        baseValue = formula(self._Attributes)
    else
        baseValue = 0
    end

    local totalAdd = 0
    local totalMulti = 1
    local overrideVal = nil
    local mods = self._Modifiers[InAttrId]
    if mods then
        ---@param mod ModifierClass
        for _, mod in ipairs(mods) do
            if mod.ModOp == ModOpDef.Add then
                totalAdd = totalAdd + mod.ModValue
            elseif mod.ModOp == ModOpDef.Multi then
                totalMulti = totalMulti * (1 + mod.ModValue)
            elseif mod.ModOp == ModOpDef.Override then
                overrideVal = mod.ModValue
            end
        end
    end
    local finalValue = overrideVal or (baseValue + totalAdd) * totalMulti
    
    self._Attributes[InAttrId] = finalValue
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

return AttrSetClass