
---
---@brief   AbilitySystem
---@author  zys
---@data    Sat Jan 03 2026 11:45:29 GMT+0800 (中国标准时间)
---

local Class3 = require('Core/Class/Class3')
local AbilityManager = require('System/Ability/Core/Ability/AbilityManager')
local AttrManager = require('System/Ability/Core/Attr/AttrManager')

---@class AbilitySystem
---@field AbilityManager AbilityManager
---@field AttrManager AttrManager
local AbilitySystem = Class3.Class('AbilitySystem')

local system = nil ---@type AbilitySystem

---@public
function AbilitySystem:Ctor()
    self.AbilityManager = AbilityManager:New(self)
    self.AttrManager = AttrManager:New(self)
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
    self.AbilityManager:InitAbilityManager()
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

return AbilitySystem