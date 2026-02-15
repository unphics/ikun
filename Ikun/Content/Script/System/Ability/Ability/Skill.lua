
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

local Class3 = require('Core/Class/class3')

---@class SkillConfig
---@field SkillKey string
---@field SkillName string
---@field SkillTemplate string

---@class SkillClass
---@field protected _Manager AbilityManager
---@field protected _ConfigData SkillConfig
---@field protected _Ability AbilityClass
local SkillClass = Class3.Class('SkillClass')

---@param InManager AbilityManager
function SkillClass:Ctor(InManager, InConfigData)
    self._Manager = InManager
    self._ConfigData = InConfigData
end

---@public
---@param InAbility AbilityClass
---@param InParams table
---@return boolean
function SkillClass:BeginSkill(InAbility, InParams)
    self._Ability = InAbility
    return true
end

---@public
---@param InDeltaTime number
function SkillClass:TickSkill(InDeltaTime)
end

---@public
function SkillClass:EndSkill()
    local manager = self._Manager
    self._Manager = nil
    self._Ability = nil
    manager:ReleaseSkill(self)
end

---@public
---@return SkillConfig
function SkillClass:GetSkillConfig()
    return self._ConfigData
end

return SkillClass