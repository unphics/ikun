
local AbilitySystem = require('System/Ability/AbilitySystem')
local TagUtil = require("System/Ability/Core/Tag/TagUtil")
local AbilityPart = require('System/Ability/Core/Ability/AbilityPart')
local ModOpDef = require("System/Ability/Core/Attr/ModOpDef")
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
    local attrMgr = AbilitySystem.Get():GetAttrManager()
    local set = attrMgr:CreateAttrSet() ---@type AttrSetClass
    local modi = attrMgr:RentModifier('BaseHealth', ModOpDef.Add, 10)
    set:AddModifier(modi)
    print('attr', set:GetAttrValue('BaseHealth'))
    print('attr', set:GetAttrValue('MaxHealth'))
    local a = 1
end

if true then
    local part = AbilityPart:New() ---@as AbilityPartClass
    part:AddAbilityToSlot('Ability1', 2)
    part:UseAbility('Ability1', {a = 1})
end