
--[[
-- -----------------------------------------------------------------------------
--  Brief       : 技能系统-属性集
--  File        : AttrSet.lua
--  Author      : zhengyanshuai
--  Date        : Sun Jan 18 2026 13:41:39 GMT+0800 (中国标准时间)
--  Description : 修改与读取属性
--  License     : MIT License
-- -----------------------------------------------------------------------------
--  Copyright (c) 2026 zhengyanshuai
-- -----------------------------------------------------------------------------
--]]

local Class3 = require('Core/Class/Class3')
local Modifier = require('System/Skill/Core/Attr/Modifier')

---@class AttrSetClass
---@field protected _Attributes table<number, number>
---@field protected _Dirty number[]
---@field protected _Modifiers ModifierClass[]
---@field protected _Manager AttrManager
local AttrSetClass = Class3.Class('AttrSetClass')

---@public
---@param InManager AttrManager
function AttrSetClass:Ctor(InManager)
    self._Manager = InManager
    self._Attributes = {}
    self._Dirty = {}
    self._Modifiers = {}
end

---@public
function AttrSetClass:GetAttrValue(InAttrKey)
    
end

---@public
---@param InModifier ModifierClass
function AttrSetClass:AddModifier(InModifier)
    table.insert(self._Modifiers, InModifier)
end

---@public
function AttrSetClass:RemoveModifier(InModifier)
    for i = 1, #self._Modifiers do
        if self._Modifiers[i] == InModifier then
            table.remove(self._Modifiers, i)
            break
        end
    end
end

---@public
function AttrSetClass:RemoveModifierBySource()
end

---@public
function AttrSetClass:RemoveModifierByBuff()
end

return AttrSetClass