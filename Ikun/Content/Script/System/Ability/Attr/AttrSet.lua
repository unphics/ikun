
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
---@field protected _OnChangedFuncs fun(self:AttrSetClass, NewValue: number, OldValue: number)[]
local AttrSetClass = Class3.Class("AttrSetClass")

---@public
---@param InManager AttrManager
function AttrSetClass:Ctor(InManager, InAttributes)
    self._Manager = InManager
    self._Attributes = InAttributes
    self._Dirty = table_util.make_arr(AttrDef.AttrCount, false)
    self._Modifiers = {}

    self:_CollectOnChangedFuncs()
end

---@public
---@param InAttrKey integer|string
function AttrSetClass:GetAttrValue(InAttrKey)
    local id = AttrDef.ToId(InAttrKey)
    if self._Dirty[id] then
        self:_UpdateAttribute(id, self._Attributes[id])
    end
    return self._Attributes[id]
end

---@public
---@param InModifier AttrModifierClass
function AttrSetClass:AddModifier(InModifier)
    local id = AttrDef.ToId(InModifier.ModAttrKey)
    local config = self._Manager:GetAttrConfig(id)
    local oldValue = self._Attributes[id]

    self:AddDirty(id) ---@todo 思考这个怎么放
    
    if config.IsModifierInfinite then
        if not self._Modifiers[id] then
            self._Modifiers[id] = {}
        end
        table.insert(self._Modifiers[id], InModifier)
    else
        self._Attributes[id] = self._Attributes[id] + InModifier.ModValue
    end

    if config.IsChangeInstant then
        self:_UpdateAttribute(id, oldValue)
    end
end

---@public
---@param InModifier AttrModifierClass
function AttrSetClass:RemoveModifier(InModifier)
    local id = AttrDef.ToId(InModifier.ModAttrKey)
    local bRemoved = false
    local mods = self._Modifiers[id]
    local oldValue = self._Attributes[id]

    if mods then
        for i = 1, #mods do
            if mods[i] == InModifier then
                table.remove(mods, i)
                bRemoved = true
                break
            end
        end
    end

    if bRemoved then
        self:AddDirty(id)
        local config = self._Manager:GetAttrConfig(id)
        if config.IsChangeInstant then
            self:_UpdateAttribute(id, oldValue)
        end
    end
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
function AttrSetClass:_UpdateAttribute(InAttrId, InOldValue)
    local config = self._Manager:GetAttrConfig(InAttrId)
    local oldValue = InOldValue
    local newValue = 0

    if config.IsModifierInfinite then
        local mods = self._Modifiers[InAttrId]
        local modValue = ModifierAdditiveStrategy[config.ModifierAdditiveStrategy](mods)
    
        local formula = self._Manager:GetAttrFormula(InAttrId)
        local baseValue = formula and formula(self:GetFormulaProxy()) or 0
    
        newValue = ModifierApplyStrategy[config.ModifierApplyStrategy](baseValue, modValue)
        self._Attributes[InAttrId] = newValue
    else
        newValue = self._Attributes[InAttrId]
    end

    self._Dirty[InAttrId] = false

    if self._OnChangedFuncs[InAttrId] then
        self._OnChangedFuncs[InAttrId](self, newValue, oldValue)
    end
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

---@private
function AttrSetClass:_CollectOnChangedFuncs()
    self._OnChangedFuncs = AttrDef.NewAttrIdArr()
    for i in ipairs(self._OnChangedFuncs) do
        local attrName = AttrDef.ToKey(i)
        local fn = self["OnAttr"..attrName.."Changed"]
        if fn then
            self._OnChangedFuncs[i] = fn
        end
    end
end

return AttrSetClass
