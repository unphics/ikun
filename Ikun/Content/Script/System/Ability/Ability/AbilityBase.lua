
--[[
-- -----------------------------------------------------------------------------
--  Brief       : 能力系统-能力-能力类
--  File        : Ability.lua
--  Author      : zhengyanshuai
--  Date        : Fri Jan 02 2026 22:29:35 GMT+0800 (中国标准时间)
--  License     : MIT License
-- -----------------------------------------------------------------------------
--  Copyright (c) 2026 zhengyanshuai
-- -----------------------------------------------------------------------------
--]]

local Class3 = require('Core/Class/Class3')
local TimeLib = require('Core/TimeLib')
local SkillFactoryClass = require('System/Ability/Ability/SkillFactory')
local TagUtils = require("System/Ability/Tag/TagUtils")

---@class AbilityConfig
---@field AbilityKey string
---@field AbilityName string
---@field AbilityTemplate string
---@field AbilityCooldown number
---@field AbilityTags number[]
---@field AbilitySkills table<string, string>
---@field AbilityTargetings table<string, string>
---@field AbilityEffects table<string, string>
---@field Projectiles table<string, string>

---@class AbilityBaseClass
---@field public AbilityTags TagContainer
---@field protected _AbilityConfigData AbilityConfig
---@field protected _AbilitySkills SkillBaseClass[]
---@field protected _OwnerPart AbilityPartClass
---@field protected _CastSkillTimeStamp number
local AbilityBaseClass = Class3.Class('AbilityBaseClass')

---@public
function AbilityBaseClass:Ctor(InAbilityConfig, InOwner)
    self._AbilityConfigData = InAbilityConfig
    self._OwnerPart = InOwner
    self.AbilityTags = TagUtils.MakeContainer()

    local tagNames = self:GetAbilityConfig().AbilityTags
    for i = 1, #tagNames do
        local tag = TagUtils.RequestTag(tagNames[i])
        if tag then
            self.AbilityTags:AddTag(tag)
        end
    end

    self._AbilitySkills = {}
    self._CastSkillTimeStamp = 0
end

---@public
function AbilityBaseClass:TickAbility(InDelaTime, InTimestampSec)
    for i = 1, #self._AbilitySkills do
        local skill = self._AbilitySkills[i]
        skill:TickSkill(InDelaTime, InTimestampSec)
    end
end

---@public
---@param InParams table
---@return boolean
function AbilityBaseClass:CanCast(InParams) -- const
    if (TimeLib.GetTimestampSec() - self._CastSkillTimeStamp) < self:GetAbilityConfig().AbilityCooldown then
        return false
    end
    return true
end

---@public
---@param InParams table
---@return boolean
function AbilityBaseClass:CastSkill(InParams)
    self:StartCooldown()
    local key = self:GetAbilityConfig().AbilitySkills.EntrySkill
    local skill = SkillFactoryClass.Get():AcquireSkill(key, self)
    if not skill then
        return false
    end
    table.insert(self._AbilitySkills, skill)
    -- self._AbilitySkills.EntrySkill = skill
    if skill:BeginSkill(self, InParams) then
        self:StartCooldown()
        return true
    else
        return false
    end
end

---@public
function AbilityBaseClass:CancelSkill()
end

---@public 由入口技能激活其他技能
---@param InSkillKey string
---@return boolean
function AbilityBaseClass:FollowSkill(InSkillKey)
    return false
end

---@public
function AbilityBaseClass:StartCooldown()
    self._CastSkillTimeStamp = TimeLib.GetTimestampSec()
end

---@public
---@return number
function AbilityBaseClass:GetCooldown() -- const
    if self:GetAbilityConfig().AbilityCooldown < 0.01 then
        return 0
    end
    return math.max(0, self:GetAbilityConfig().AbilityCooldown - (TimeLib.GetTimestampSec() - self._CastSkillTimeStamp))
end

---@public
function AbilityBaseClass:GetTargetsInRange() -- const
end

---@public
---@return AbilityConfig
function AbilityBaseClass:GetAbilityConfig() -- const
    return self._AbilityConfigData
end

---@public
---@return AbilityPartClass
function AbilityBaseClass:GetAbilityOwnerPart() -- const
    return self._OwnerPart
end

return AbilityBaseClass