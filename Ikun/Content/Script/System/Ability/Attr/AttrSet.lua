
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
local table_util = require("Core/Utils/table_util")

---@class AttrSetClass
---@field protected _Attributes table<integer, number>
---@field protected _Dirty table<integer, boolean> 后面用位运算
---@field protected _Modifiers table<integer, AttrModifierClass[]>
---@field protected _Manager AttrManager
local AttrSetClass = Class3.Class("AttrSetClass")

---@public
---@param InManager AttrManager
function AttrSetClass:Ctor(InManager, InAttributes)
    self._Manager = InManager
    self._Attributes = InAttributes
    self._Dirty = table_util.make_arr(AttrDef.AttrCount, false)
    self._Modifiers = {}
end

---@public
---@param InAttrKey integer|string
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
    self:AddDirty(id) ---@todo 思考这个怎么放
    
    if self._Manager:GetAttrConfig(id).IsModifierInfinite then
        if not self._Modifiers[id] then
            self._Modifiers[id] = {}
        end
        table.insert(self._Modifiers[id], InModifier)
    else
        self._Attributes[id] = self._Attributes[id] + InModifier.ModValue
    end
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

---@private
---@param InAttrKey integer
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

---@private
---@param InAttrKey integer
function AttrSetClass:RemoveDirty(InAttrKey)
    local id = AttrDef.ToId(InAttrKey)
    self._Dirty[id] = false
end

---@private
---@param InAttrKey integer
function AttrSetClass:IsDirty(InAttrKey)
    local id = AttrDef.ToId(InAttrKey)
    return self._Dirty[id]
end

local ModifierApplyStrategy = {
    Additive = function(InBaseValue, InModValue)
        return InBaseValue + InModValue
    end
}

local ModifierAdditiveStrategy = {
    Additive = function(InMods)
        local modValue = 0
        if InMods then
            for _, mod in ipairs(InMods) do
                modValue = modValue + mod.ModValue
            end
        end
        return modValue
    end
}

---@protected
---@param InAttrId integer
function AttrSetClass:_UpdateAttribute(InAttrId)
    local config = self._Manager:GetAttrConfig(InAttrId)

    local mods = self._Modifiers[InAttrId]
    local modValue = ModifierAdditiveStrategy[config.ModifierAdditiveStrategy](mods)

    local formula = self._Manager:GetAttrFormula(InAttrId)
    local baseValue = formula and formula(self:GetFormulaProxy()) or 0

    self._Attributes[InAttrId] = ModifierApplyStrategy[config.ModifierApplyStrategy](baseValue, modValue)
    self._Dirty[InAttrId] = false
end

---@public
---@return table<integer, number>
function AttrSetClass:GetFormulaProxy()
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
    local str = string.format("\nModifiers:")
    for id, modifiers in pairs(self._Modifiers) do
        for i = 1, #modifiers do
            local modi = modifiers[i] ---@type AttrModifierClass
            str = string.format("%s\nId=%i, Attr=%s, Op=%s, Value=%i", str, modi.ModId, AttrDef.ToKey(modi.ModAttrKey), modi.ModOp, modi.ModValue)
        end
    end
    log.dev(str)
end

return AttrSetClass
