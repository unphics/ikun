
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
local Time = require('Core/Time')

---@class WaitSkillClass: SkillBaseClass
local WaitSkillClass = Class3.Class('WaitSkillClass', SkillBaseClass)

local mtg = UE.UObject.Load('/Game/Ikun/Chr/Mage/Montage/Mtg_Fire_R.Mtg_Fire_R')

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
    local avatar = part:GetOwnerRole().Avatar
    if not obj_util.is_valid(avatar) then
        log.dev("qqq 1")
    end
    local animInst = avatar.Mesh:GetAnimInstance()
    log.dev("qqq 1.1", animInst:IsAnyMontagePlaying(), obj_util.dispname(avatar))
    animInst.OnMontageStarted:Add(avatar,  self.on_start)
    if not obj_util.is_valid(mtg) then
        log.dev("qqq 2")
    end
    local time = animInst:Montage_Play(mtg, 1, UE.EMontagePlayReturnType.Duration, 0, true)
    log.dev("qqq 3", time, animInst:IsAnyMontagePlaying())
    return true
end

function WaitSkillClass:on_start(mtg)
    log.dev("WaitSkillClass:on_start", obj_util.dispname(mtg))
end

---@override
function WaitSkillClass:TickSkill(InDeltaTime)
    SkillBaseClass.TickSkill(self, InDeltaTime)
    if self.WaitTiming > self.WaitTotalTime then
        self:EndSkill()
        return
    end
    self.WaitTiming = self.WaitTiming + InDeltaTime

    local part = self:GetSkillOwner() ---@as AbilityPartClass
    local avatar = part:GetOwnerRole().Avatar
    local animInst = avatar.Mesh:GetAnimInstance()
    local b = animInst:IsAnyMontagePlaying()
    local mtg = animInst:GetCurrentActiveMontage()
    log.dev("tick", obj_util.dispname(mtg))
end

function WaitSkillClass:OnEndSKill()
    local part = self:GetSkillOwner() ---@as AbilityPartClass
    local avatar = part:GetOwnerRole().Avatar
    local animInst = avatar.Mesh:GetAnimInstance()
    animInst.OnMontageStarted:Remove(avatar, self.on_start)
    log.mark("WaitSkillClass:OnEndSKill()")
end

return WaitSkillClass