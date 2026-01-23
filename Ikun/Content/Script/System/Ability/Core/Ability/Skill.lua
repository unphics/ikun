
--[[
-- -----------------------------------------------------------------------------
--  Brief       : SkillClass
--  File        : Skill.lua
--  Author      : zhengyanshuai
--  Date        : Fri Jan 02 2026 22:31:04 GMT+0800 (中国标准时间)
--  Description : 能力系统-技能类
--  License     : MIT License
-- -----------------------------------------------------------------------------
--  Copyright (c) 2026 zhengyanshuai
-- -----------------------------------------------------------------------------
--]]

local Class3 = require('Core/Class/Class3')

---@class SkillConfig
---@field SkillKey string
---@field SkillName string

---@class SkillClass
---@field _SkillKey string
---@field _Ability AbilityClass
---@field _Manager AbilityManager
local SkillClass = Class3.Class('SkillClass')

---@param InManager AbilityManager
function SkillClass:Ctor(InManager)
    self._Manager = InManager
end

---@public
---@param InAbility AbilityClass
---@param InSkillKey string
---@param InParams table
function SkillClass:DoBeginSkill(InAbility, InSkillKey, InParams)
    self._Ability = InAbility
    self._SkillKey = InSkillKey
    self:OnBeginSkill(InParams)
end

---@protected
---@param InParams table
function SkillClass:OnBeginSkill(InParams)
end

---@public
---@param DeltaTime number
function SkillClass:UpdateSkill(DeltaTime)
    self:OnUpdateSkill(DeltaTime)
end

---@protected
---@param DeltaTime number
function SkillClass:OnUpdateSkill(DeltaTime)
end

---@protected
function SkillClass:DoEndSkill()
end

---@public
function SkillClass:OnEndSkill()
end

---@protected
function SkillClass:OnPostEndSkill()
    local manager = self._Manager
    self._Manager = nil
    self._Ability = nil
    manager:RecycleSkill(self)
end

return SkillClass