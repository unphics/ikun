
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

local Class3 = require("Core/Class/Class3")
local SkillBaseClass = require("System/Ability/Ability/SkillBase")
local log = require("Core/Log/log")

local Task = require("System/Ability/Task/Task")

---@class WaitSkillClass: SkillBaseClass
local WaitSkillClass = Class3.Class('WaitSkillClass', SkillBaseClass)

local mtg = UE.UObject.Load('/Game/Ikun/Chr/Mage/Montage/Mtg_Equip.Mtg_Equip')

---@override
function WaitSkillClass:BeginSkill(InAbility, InParams)
    SkillBaseClass.BeginSkill(self, InAbility, InParams)
    self.WaitTotalTime = self:GetSkillConfig().WaitTime
    self.WaitTiming = 0.0

    local part = self:GetSkillOwner() ---@as AbilityPartClass
    local set = part:GetAttrSet()
    -- local effector = part:MakeEffector("Burn")
    local effector = part:MakeEffector("Burn")
    if effector then
        part:TryApplyEffectorToSelf(effector)
    end
    local task = Task.PlayMontageAndWait(self, mtg)
    self.fn = function() log.mark("task.OnMontageEnd") end
    task.OnMontageEnd:Add(self, self.fn)
    task:Ready()
    return true
end

---@override
function WaitSkillClass:TickSkill(InDeltaTime)
    SkillBaseClass.TickSkill(self, InDeltaTime)
    if self.WaitTiming > self.WaitTotalTime then
        self:EndSkill()
        return
    end
    self.WaitTiming = self.WaitTiming + InDeltaTime
end

function WaitSkillClass:OnEndSKill()
    log.mark("WaitSkillClass:OnEndSKill()")
end

return WaitSkillClass