
--[[
-- -----------------------------------------------------------------------------
--  Brief       : 能力系统-技能-技能基类
--  File        : Skill.lua
--  Author      : zhengyanshuai
--  Date        : Fri Jan 02 2026 22:31:04 GMT+0800 (中国标准时间)
--  License     : MIT License
-- -----------------------------------------------------------------------------
--  Copyright (c) 2026 zhengyanshuai
-- -----------------------------------------------------------------------------
--]]

local Class3 = require("Core/Class/Class3")
local SkillFactoryClass = require("System/Ability/Ability/SkillFactory")

---@class SkillBaseClass
---@field protected _Manager AbilityManager
---@field protected _ConfigData SkillConfig
---@field protected _BelongAbility AbilityClass
local SkillBaseClass = Class3.Class("SkillBaseClass")

function SkillBaseClass:Ctor(InConfigData)
    self._ConfigData = InConfigData
end

---@public
---@param InBelongAbility AbilityClass
---@param InParams table
---@return boolean
function SkillBaseClass:BeginSkill(InBelongAbility, InParams)
    self._BelongAbility = InBelongAbility
    return true
end

---@public
function SkillBaseClass:TickSkill(InDeltaTime, InTimestampSec)
end

---@public
function SkillBaseClass:EndSkill()
    self:OnEndSKill()
    self._BelongAbility = nil
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
    return self._BelongAbility:GetAbilityOwnerPart()
end

return SkillBaseClass