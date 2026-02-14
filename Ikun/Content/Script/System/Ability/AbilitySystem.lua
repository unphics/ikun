
---
---@brief   AbilitySystem
---@author  zys
---@data    Sat Jan 03 2026 11:45:29 GMT+0800 (中国标准时间)
---

local Class3 = require('Core/Class/Class3')
local AbilityManager = require('System/Ability/Ability/AbilityManager')
local AttrManager = require('System/Ability/Attr/AttrManager')
local BuffManager = require('System/Ability/Buff/BuffManager')
local Time = require("Core/Time")

---@class AbilitySystem
---@field AbilityManager AbilityManager
---@field AttrManager AttrManager
---@field BuffManager BuffManager
local AbilitySystem = Class3.Class('AbilitySystem')

local system = nil ---@type AbilitySystem

---@public
function AbilitySystem:Ctor()
    self.AttrManager = AttrManager:New(self)
    self.BuffManager = BuffManager:New(self)
    self.AbilityManager = AbilityManager:New(self)
end

---@public
---@return AbilitySystem
function AbilitySystem.Get()
    if not system then
        system = AbilitySystem:New()
    end
    return system
end

---@public
function AbilitySystem:InitAbilitySystem()
    self.AttrManager:InitAttrManager()
    self.BuffManager:InitBuffManager()
    self.AbilityManager:InitAbilityManager()
end

---@public
---@param InDeltaTime number
function AbilitySystem:TickAbilitySystem(InDeltaTime)
    self.BuffManager:TickBuffManager(InDeltaTime)
end

---@public
---@return AbilityManager
function AbilitySystem:GetAbilityManager()
    return self.AbilityManager
end

---@public
---@return AttrManager
function AbilitySystem:GetAttrManager()
    return self.AttrManager
end

---@public
---@return BuffManager
function AbilitySystem:GetBuffManager()
    return self.BuffManager
end

---@public
---@return number
function AbilitySystem:GetNowMs()
    return Time.GetTimestampMS()
end

return AbilitySystem