
---
---@brief   SkillSystem
---@author  zys
---@data    Sat Jan 03 2026 11:45:29 GMT+0800 (中国标准时间)
---

local Class3 = require('Core/Class/Class3')
local SkillManager = require('System/Skill/Core/Skill/SkillManager')

---@class SkillSystem
---@field SkillManager SkillManager
local SkillSystem = Class3.Class('SkillSystem')

local system = nil

---@public
function SkillSystem:Ctor()
    self.SkillManager = SkillManager:New(self)
end

---@public
---@return SkillSystem
function SkillSystem.Get()
    if not system then
        system = SkillSystem:New()
    end
    return system
end

---@public
function SkillSystem:InitSkillSystem()
    self.SkillManager:InitSkillManager()
end

---@public
---@return SkillManager
function SkillSystem:GetSkillManager()
    return self.SkillManager
end

return SkillSystem