
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
end

---@public [Get] [Attribute]
---@param InAttrKey number|string
function AttrSetClass:GetAttrValue(InAttrKey)
    return self._Attributes[AttrDef.ToId(InAttrKey)]
end

---@public [Add] [Modifier]
---@param InModifier ModifierClass
function AttrSetClass:AddModifier(InModifier)
    table.insert(self._Modifiers, InModifier)
end

---@public [Remove] [Modifier]
---@param InModifier ModifierClass
function AttrSetClass:RemoveModifier(InModifier)
    for i = 1, #self._Modifiers do
        if self._Modifiers[i] == InModifier then
            table.remove(self._Modifiers, i)
            break
        end
    end
end

---@public [Remove] [Modifier]
---@param InSource any
function AttrSetClass:RemoveModifierBySource(InSource)
    for i = 1, #self._Modifiers do
        if self._Modifiers[i].ModSource == InSource then
            table.remove(self._Modifiers, i)
            break
        end
    end
end

---@public [Remove] [Modifier]
---@param InId number
function AttrSetClass:RemoveModifierById(InId)
    for i = 1, #self._Modifiers do
        if self._Modifiers[i].ModId == InId then
            table.remove(self._Modifiers, i)
            break
        end
    end
end

---@public [Dirty]
---@param InAttrKey number
function AttrSetClass:AddDirty(InAttrKey)
    self._Dirty[InAttrKey] = true
end

---@public [Dirty]
---@param InAttrKey number
function AttrSetClass:RemoveDirty(InAttrKey)
    self._Dirty[InAttrKey] = false
end

return AttrSetClass