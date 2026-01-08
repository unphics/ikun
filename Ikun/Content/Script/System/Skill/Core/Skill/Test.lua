
local SkillSystem = require('System/Skill/SkillSystem')
local SkillPart = require('System/Skill/Core/Skill/SkillPart')

SkillSystem.Get():InitSkillSystem()

local part = SkillPart:New() ---@as SkillPartClass
part:AddArmsToSlot('Arms1', 2)
part:UseArms('Arms1', {a = 1})