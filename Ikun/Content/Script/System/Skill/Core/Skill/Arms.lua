
--[[
-- -----------------------------------------------------------------------------
--  Brief       : ArmsClass
--  File        : Arms.lua
--  Author      : zhengyanshuai
--  Date        : Fri Jan 02 2026 22:29:35 GMT+0800 (中国标准时间)
--  Description : 技能系统-武器类
--  License     : MIT License
-- -----------------------------------------------------------------------------
--  Copyright (c) 2026 zhengyanshuai
-- -----------------------------------------------------------------------------
--]]

local Class3 = require('Core/Class/Class3')
local Time = require('Core/Time')

---@class ArmsConfig
---@field ArmsKey string
---@field ArmsName string
---@field ArmsCooldown number
---@field ArmsSkills table<string, string>
---@field ArmsTargetings table<string, string>
---@field ArmsEffects table<string, string>
---@field Projectiles table<string, string>

---@class ArmsClass
---@field _ArmsKey string
---@field _Manager SkillManager
---@field _ArmsCooldown number 武器的冷却
---@field _ArmsSkills table<string, SkillClass>
---@field _UseSkillTimeStamp number
local ArmsClass = Class3.Class('ArmsClass')

---@public
function ArmsClass:Ctor(InManager, InArmsKey)
    self._Manager = InManager
    self._ArmsKey = InArmsKey
    self._ArmsSkills = {}
    self._UseSkillTimeStamp = 0
    self:InitArms(InArmsKey)
end

---@public
function ArmsClass:InitArms(InArmsKey)
    local config = self:GetArmsConfig()
    self._ArmsCooldown = tonumber(config.ArmsCooldown)
end

---@public
---@param InParams table
function ArmsClass:UseSkill(InParams)
    self:StartCooldown()
    local config = self:GetArmsConfig()
    local key = config.ArmsSkills.EntrySkill
    local skill = self._Manager:SpawnSkill(key)
    self._ArmsSkills.EntrySkill = skill
    self:OnUseSkill(skill, key, InParams)
end

---@public
---@param InSkill SkillClass
---@param InSkillKey string
---@param InParams table
function ArmsClass:OnUseSkill(InSkill, InSkillKey, InParams)
    InSkill:DoBeginSkill(self, InSkillKey, InParams)
end

---@public 由入口技能激活其他技能
---@param InSkillKey string
---@return boolean
function ArmsClass:FollowSkill(InSkillKey)
end

---@public
function ArmsClass:OnSkillComplete()
end

---@public
---@param Params table
---@return boolean
function ArmsClass:CanUse(Params)
    if (Time.GetTimestampSec() - self._UseSkillTimeStamp) < self._ArmsCooldown then
        return false
    end
    return true
end

---@public
function ArmsClass:StartCooldown()
    self._UseSkillTimeStamp = Time.GetTimestampSec()
end

---@public
---@return number
function ArmsClass:GetCooldown()
    if self._ArmsCooldown < 0.01 then
        return 0
    end
    return math.max(0, self._ArmsCooldown - (Time.GetTimestampSec() - self._UseSkillTimeStamp))
end

---@public
function ArmsClass:GetTargetsInRange()
end

---@public
---@return ArmsConfig
function ArmsClass:GetArmsConfig()
    return self._Manager:LookupArmsConfig(self._ArmsKey)
end

return ArmsClass