
--[[
-- -----------------------------------------------------------------------------
--  Brief       : HitSelfSkillClass
--  File        : HitSelfSkill.lua
--  Author      : zhengyanshuai
--  Date        : Mon May 04 2026 16:09:27 GMT+0800 (中国标准时间)
--  Description : 测试技能-打自己
--  License     : MIT License
-- -----------------------------------------------------------------------------
--  Copyright (c) 2026 zhengyanshuai
-- -----------------------------------------------------------------------------
--]]

local Class3 = require("Core/Class/Class3")
local SkillBaseClass = require("System/Ability/Ability/SkillBase")
local log = require("Core/Log/log")
local Task = require("System/Ability/Task/Task")
local TargetLib = require("System/Ability/Target/TargetLib")

---@class HitSelfSkillClass: SkillBaseClass
local HitSelfSkillClass = Class3.Class("HitSelfSkillClass", SkillBaseClass)

---@override
function HitSelfSkillClass:BeginSkill(InBelongAbility, InParams)
    SkillBaseClass.BeginSkill(self, InBelongAbility, InParams)
    log.dev("qqq")
    local avatar = self:GetSkillOwnerPart():GetOwnerRole().Avatar
    local center = avatar:K2_GetActorLocation()
    local objs = {UE.EObjectTypeQuery.Pawn}
    local hits = TargetLib.MakeSphereInst(avatar, center, 100, objs, {})
    if hits:Length() > 0 then
        local hit = hits:Get(1) ---@type FHitResult
        local actor = hit.Component:GetOwner() ---@type BP_ChrBase
        log.dev("qqq", obj_util.dispname(actor))
        local ap = actor:GetRole().AbilityPart
    end
    self:EndSkill()
    return true
end

return HitSelfSkillClass