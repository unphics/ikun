
local SkillSystem = require('System/Skill/SkillSystem')
local TagUtil = require("System/Skill/Core/Tag/TagUtil")
local SkillPart = require('System/Skill/Core/Skill/SkillPart')

SkillSystem.Get():InitSkillSystem()

if false then
    local tag = TagUtil.RequestTag('skill.type.active')
    local container = TagUtil.MakeContainer()
    print('xxx', container:HasTag(tag))
    container:AddTag(tag)
    print('xxx', container:HasTag(tag))
    container:AddTag(tag)
    print('xxx', container:HasTag(tag))
    container:RemoveTag(tag)
    print('xxx', container:HasTag(tag))
    container:RemoveTag(tag)
    print('xxx', container:HasTag(tag))
end

if true then
    
end

if false then
    local part = SkillPart:New() ---@as SkillPartClass
    part:AddArmsToSlot('Arms1', 2)
    part:UseArms('Arms1', {a = 1})
end