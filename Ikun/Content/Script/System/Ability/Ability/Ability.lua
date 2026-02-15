
--[[
-- -----------------------------------------------------------------------------
--  Brief       : AbilityClass
--  File        : Ability.lua
--  Author      : zhengyanshuai
--  Date        : Fri Jan 02 2026 22:29:35 GMT+0800 (中国标准时间)
--  Description : 能力系统-能力类
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
---@field protected _Manager AbilityManager
---@field protected _AbilityConfigData AbilityConfig
---@field protected _AbilitySkills table<string, SkillClass>
---@field protected _UseSkillTimeStamp number
local AbilityClass = Class3.Class('AbilityClass')

---@public
function AbilityClass:Ctor(InManager, InAbilityConfig)
    self._Manager = InManager
    self._AbilityConfigData = InAbilityConfig

    self._AbilitySkills = {}
    self._UseSkillTimeStamp = 0
end

---@public
---@param InParams table
---@return boolean
function AbilityClass:CanUse(InParams) -- const
    if (Time.GetTimestampSec() - self._UseSkillTimeStamp) < self:GetAbilityConfig().AbilityCooldown then
        return false
    end
    return true
end

---@public
---@param InParams table
---@return boolean
function AbilityClass:UseSkill(InParams)
    self:StartCooldown()
    local key = self:GetAbilityConfig().AbilitySkills.EntrySkill
    local skill = self._Manager:AcquireSkill(key)
    self._AbilitySkills.EntrySkill = skill
    if skill:BeginSkill(self, key, InParams) then
        self:StartCooldown()
        return true
    else
        return false
    end
end

---@public 由入口技能激活其他技能
---@param InSkillKey string
---@return boolean
function AbilityClass:FollowSkill(InSkillKey)
    return false
end

---@public
function AbilityClass:StartCooldown()
    self._UseSkillTimeStamp = Time.GetTimestampSec()
end

---@public
---@return number
function AbilityClass:GetCooldown() -- const
    if self:GetAbilityConfig().AbilityCooldown < 0.01 then
        return 0
    end
    return math.max(0, self:GetAbilityConfig().AbilityCooldown - (Time.GetTimestampSec() - self._UseSkillTimeStamp))
end

---@public
function AbilityClass:GetTargetsInRange() -- const
end

---@public
---@return AbilityConfig
function AbilityClass:GetAbilityConfig() -- const
    return self._AbilityConfigData
end

return AbilityClass