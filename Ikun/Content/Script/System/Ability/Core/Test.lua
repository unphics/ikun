
local AbilitySystem = require('System/Ability/AbilitySystem')
local TagUtil = require("System/Ability/Core/Tag/TagUtil")
local AbilityPart = require('System/Ability/Core/Ability/AbilityPart')
-- local log = require('Core/Log/log') ---@as log

AbilitySystem.Get():InitAbilitySystem()

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

if true then
    local part = AbilityPart:New() ---@as AbilityPartClass
    part:AddAbilityToSlot('Ability1', 2)
    part:UseAbility('Ability1', {a = 1})
end