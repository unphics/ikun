
--[[
-- -----------------------------------------------------------------------------
--  Brief       : WaitSkillClass
--  File        : WaitSkill.lua
--  Author      : zhengyanshuai
--  Date        : Fri Jan 02 2026 22:29:35 GMT+0800 (中国标准时间)
--  Description : 技能-等待
--  License     : MIT License
-- -----------------------------------------------------------------------------
--  Copyright (c) 2026 zhengyanshuai
-- -----------------------------------------------------------------------------
--]]

local Class3 = require("Core/Class/class3")
local SkillClass = require("System/Ability/Ability/Skill")
local log = require("Core/Log/log")
local Time = require('Core/Time')

---@class WaitSkillClass: SkillClass
local WaitSkillClass = Class3.Class('WaitSkillClass', SkillClass)

---@override
function WaitSkillClass:BeginSkill(InAbility, InParams)
    SkillClass.BeginSkill(self, InAbility, InParams)
    self.WaitTotalTime = self:GetSkillConfig().WaitTime
    self.WaitTiming = 0.0

    local part = self:GetSkillOwner() ---@as AbilityPartClass
    local set = part:GetAttrSet()
    local effector = part:MakeEffector("Burn")
    if effector then
        part:TryApplyEffectorToSelf(effector)
    end
    return true
end

---@override
function WaitSkillClass:TickSkill(InDeltaTime)
    SkillClass.TickSkill(self, InDeltaTime)
    if self.WaitTiming > self.WaitTotalTime then
        self:EndSkill()
        return
    end
    self.WaitTiming = self.WaitTiming + InDeltaTime
end

return WaitSkillClass