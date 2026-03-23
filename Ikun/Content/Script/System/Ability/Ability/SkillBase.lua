
--[[
-- -----------------------------------------------------------------------------
--  Brief       : SkillBaseClass
--  File        : Skill.lua
--  Author      : zhengyanshuai
--  Date        : Fri Jan 02 2026 22:31:04 GMT+0800 (中国标准时间)
--  Description : 能力系统-技能类
--  License     : MIT License
-- -----------------------------------------------------------------------------
--  Copyright (c) 2026 zhengyanshuai
-- -----------------------------------------------------------------------------
--]]

local Class3 = require("Core/Class/Class3")

---@class SkillConfig
---@field SkillKey string
---@field SkillName string
---@field SkillTemplate string

---@class SkillBaseClass
---@field protected _Manager AbilityManager
---@field protected _ConfigData SkillConfig
---@field protected _Ability AbilityClass
local SkillBaseClass = Class3.Class("SkillBaseClass")

---@param InManager AbilityManager
function SkillBaseClass:Ctor(InManager, InConfigData)
    self._Manager = InManager
    self._ConfigData = InConfigData
end

---@public
---@param InAbility AbilityClass
---@param InParams table
---@return boolean
function SkillBaseClass:BeginSkill(InAbility, InParams)
    self._Ability = InAbility
    return true
end

---@public
---@param InDeltaTime number
function SkillBaseClass:TickSkill(InDeltaTime)
end

---@public
function SkillBaseClass:EndSkill()
    self:OnEndSKill()
    local manager = self._Manager
    self._Manager = nil
    self._Ability = nil
    manager:ReleaseSkill(self)
end
---@protected
function SkillBaseClass:OnEndSKill()
end

---@public
---@return SkillConfig
function SkillBaseClass:GetSkillConfig() --const
    return self._ConfigData
end

---@public
---@return table
function SkillBaseClass:GetSkillOwner() -- const
    return self._Ability:GetAbilityOwner()
end

return SkillBaseClass