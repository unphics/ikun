
--[[
-- -----------------------------------------------------------------------------
--  Brief       : AbilityClass
--  File        : Ability.lua
--  Author      : zhengyanshuai
--  Date        : Fri Jan 02 2026 22:29:35 GMT+0800 (中国标准时间)
--  Description : 技能系统-能力类
--  License     : MIT License
-- -----------------------------------------------------------------------------
--  Copyright (c) 2026 zhengyanshuai
-- -----------------------------------------------------------------------------
--]]

local Class3 = require('Core/Class/Class3')
local Time = require('Core/Time')

---@class AbilityConfig
---@field AbilityKey string
---@field AbilityName string
---@field AbilityCooldown number
---@field AbilitySkills table<string, string>
---@field AbilityTargetings table<string, string>
---@field AbilityEffects table<string, string>
---@field Projectiles table<string, string>

---@class AbilityClass
---@field _AbilityKey string
---@field _Manager AbilityManager
---@field _AbilityCooldown number 武器的冷却
---@field _AbilitySkills table<string, SkillClass>
---@field _UseSkillTimeStamp number
local AbilityClass = Class3.Class('AbilityClass')

---@public
function AbilityClass:Ctor(InManager, InAbilityKey)
    self._Manager = InManager
    self._AbilityKey = InAbilityKey
    self._AbilitySkills = {}
    self._UseSkillTimeStamp = 0
    self:InitAbility(InAbilityKey)
end

---@public
function AbilityClass:InitAbility(InAbilityKey)
    local config = self:GetAbilityConfig()
    self._AbilityCooldown = tonumber(config.AbilityCooldown)
end

---@public
---@param InParams table
function AbilityClass:UseSkill(InParams)
    self:StartCooldown()
    local config = self:GetAbilityConfig()
    local key = config.AbilitySkills.EntrySkill
    local skill = self._Manager:SpawnSkill(key)
    self._AbilitySkills.EntrySkill = skill
    self:OnUseSkill(skill, key, InParams)
end

---@public
---@param InSkill SkillClass
---@param InSkillKey string
---@param InParams table
function AbilityClass:OnUseSkill(InSkill, InSkillKey, InParams)
    InSkill:DoBeginSkill(self, InSkillKey, InParams)
end

---@public 由入口技能激活其他技能
---@param InSkillKey string
---@return boolean
function AbilityClass:FollowSkill(InSkillKey)
end

---@public
function AbilityClass:OnSkillComplete()
end

---@public
---@param Params table
---@return boolean
function AbilityClass:CanUse(Params)
    if (Time.GetTimestampSec() - self._UseSkillTimeStamp) < self._AbilityCooldown then
        return false
    end
    return true
end

---@public
function AbilityClass:StartCooldown()
    self._UseSkillTimeStamp = Time.GetTimestampSec()
end

---@public
---@return number
function AbilityClass:GetCooldown()
    if self._AbilityCooldown < 0.01 then
        return 0
    end
    return math.max(0, self._AbilityCooldown - (Time.GetTimestampSec() - self._UseSkillTimeStamp))
end

---@public
function AbilityClass:GetTargetsInRange()
end

---@public
---@return AbilityConfig
function AbilityClass:GetAbilityConfig()
    return self._Manager:LookupAbilityConfig(self._AbilityKey)
end

return AbilityClass