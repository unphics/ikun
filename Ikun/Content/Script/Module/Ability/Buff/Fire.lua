
--[[
-- -----------------------------------------------------------------------------
--  Brief       : FireClass
--  File        : Fire.lua
--  Author      : zhengyanshuai
--  Date        : Fri Jan 02 2026 22:29:35 GMT+0800 (中国标准时间)
--  Description : 增益-灼伤
--  License     : MIT License
-- -----------------------------------------------------------------------------
--  Copyright (c) 2026 zhengyanshuai
-- -----------------------------------------------------------------------------
--]]

local Class3 = require("Core/Class/class3")
local BuffBaseClass = require("System/Ability/Buff/BuffBase")
local Time = require("Core/Time")
local log = require("Core/Log/log")
local AbilitySystem = require('System/Ability/AbilitySystem')
local AttrDef = require("System/Ability/Attr/AttrDef")

---@class FireClass: BuffBaseClass
local FireClass = Class3.Class("FireClass", BuffBaseClass)

function FireClass:ApplyBuff(InTimestampSec)
    BuffBaseClass.ApplyBuff(self, InTimestampSec)
    local modifier = AbilitySystem.Get():GetAttrManager():AcquireModifier('BaseHealth', 10)
    self.fireModifier = modifier
    self.BuffTarget:GetAttrSet():AddModifier(modifier)
    -- self.BuffTarget:GetAttrSet():PrintModifiers()
end

function FireClass:TickBuff(InDeltaTime, InTimestampSec)
    BuffBaseClass.TickBuff(self, InDeltaTime, InTimestampSec)
end

function FireClass:DeactivateBuff()
    BuffBaseClass.DeactivateBuff(self)
    self.BuffTarget:GetAttrSet():RemoveModifier(self.fireModifier)
    -- self.BuffTarget:GetAttrSet():PrintModifiers()
end

return FireClass