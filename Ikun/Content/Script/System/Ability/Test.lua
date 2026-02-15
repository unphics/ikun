
local AbilitySystem = require('System/Ability/AbilitySystem')
local TagUtil = require("System/Ability/Tag/TagUtil")
local AbilityPart = require('System/Ability/Part/AbilityPart')
local ModOpDef = require("System/Ability/Attr/ModOpDef")
local AttrDef = require("System/Ability/Attr/AttrDef")
local log = require('Core/Log/log') ---@as log

local testlog = function(...)
    log.log(...)
end

testlog('------------- AbilitySystem BeginTest -------------')

AbilitySystem.Get():InitAbilitySystem()

if false then
    local tag = TagUtil.RequestTag('skill.type.active')
    local container = TagUtil.MakeContainer()
    testlog('xxx', container:HasTag(tag))
    container:AddTag(tag)
    testlog('xxx', container:HasTag(tag))
    container:AddTag(tag)
    testlog('xxx', container:HasTag(tag))
    container:RemoveTag(tag)
    testlog('xxx', container:HasTag(tag))
    container:RemoveTag(tag)
    testlog('xxx', container:HasTag(tag))
end

if true then
    local attrMgr = AbilitySystem.Get():GetAttrManager()
    local set = attrMgr:CreateAttrSet({"Health"}) ---@type AttrSetClass

    local mod_baseHealth_add_10 = attrMgr:RentModifier('BaseHealth', ModOpDef.Add, 10)
    testlog('attr add modi (BaseHealth Add 10)')
    set:AddModifier(mod_baseHealth_add_10)
    testlog('attr', set:GetAttrValue('BaseHealth'))
    testlog('attr', set:GetAttrValue('MaxHealth'))

    -- local mod_FlatHealth_add_10 = attrMgr:RentModifier('FlatHealth', ModOpDef.Add, 10)
    -- print('attr add modi (FlatHealth Add 10)')
    -- set:AddModifier(mod_FlatHealth_add_10)
    -- print('attr', set:IsDirty('MaxHealth'))
    -- print('attr', set:GetAttrValue('FlatHealth'))
    -- print('attr', set:GetAttrValue('MaxHealth'))
    
    -- set:RemoveModifier(mod_baseHealth_add_10)
    -- print('attr remove modi (BaseHealth Add 10)')
    -- print('attr', set:GetAttrValue('BaseHealth'))
    -- print('attr', set:GetAttrValue('MaxHealth'))

    local mod_perH_add_10 = attrMgr:RentModifier(AttrDef.Attr.PercentHealth, ModOpDef.Add, 0.1)
    set:AddModifier(mod_perH_add_10)
    testlog('attr', set:GetAttrValue(AttrDef.Attr.PercentHealth))
    testlog('attr', set:GetAttrValue('MaxHealth'))
    local a = 1
end

if true then
    local part = AbilityPart:New(nil) ---@type AbilityPartClass
    local buff = part:MakeBuff('Buff1')
    part:ApplyBuffToSelf(buff)
    testlog('buff', buff)
end

if false then
    local part = AbilityPart:New() ---@as AbilityPartClass
    part:AddAbilityToSlot(2, 'Ability1')
    part:UseAbility('Ability1', {a = 1})
end

testlog('------------- AbilitySystem EndTest -------------')