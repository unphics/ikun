
--[[
-- -----------------------------------------------------------------------------
--  Brief       : 能力系统-属性-属性工厂
--  File        : AttrFactory.lua
--  Author      : zhengyanshuai
--  Date        : Thu Apr 23 2026 20:55:28 GMT+0800 (中国标准时间)
--  Description : 属性工厂
--  License     : MIT License
-- -----------------------------------------------------------------------------
--  Copyright (c) 2026 zhengyanshuai
-- -----------------------------------------------------------------------------
--]]

local Class3 = require('Core/Class/Class3')
local AttrDef = require("System/Ability/Attr/AttrDef")
local AttrModifierClass = require("System/Ability/Attr/AttrModifier")

---@class AttrModifierFactoryClass
---@field private __AttrModGenId integer
local AttrModifierFactoryClass = Class3.Class("AttrModifierFactoryClass")

local factory = nil

---@public
---@return AttrModifierFactoryClass
function AttrModifierFactoryClass.Get()
    if not factory then
        factory = AttrModifierFactoryClass:New()
    end
    return factory
end

function AttrModifierFactoryClass:Ctor()
    self.__AttrModGenId = 0
end

---@public
---@param InAttrKey integer|string
---@param InModValue number
---@param InPriority? integer
---@return AttrModifierClass
function AttrModifierFactoryClass:AcquireModifier(InAttrKey, InModValue, InPriority)
    InPriority = InPriority or 0
    self.__AttrModGenId = self.__AttrModGenId + 1
    return AttrModifierClass(self.__AttrModGenId, InModValue, AttrDef.ToId(InAttrKey), InPriority)
end

---@public
---@param InModifier AttrModifierClass
function AttrModifierFactoryClass:ReleaseModifier(InModifier)
end

return AttrModifierFactoryClass