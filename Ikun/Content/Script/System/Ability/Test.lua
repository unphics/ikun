
--[[
-- -----------------------------------------------------------------------------
--  Brief       : AbilitySystem-Test
--  File        : Test.lua
--  Author      : zhengyanshuai
--  Date        : Tue Mar 10 2026 14:19:40 GMT+0800 (中国标准时间)
--  Description : 能力系统测试
--  License     : MIT License
-- -----------------------------------------------------------------------------
--  Copyright (c) 2025-2026 zhengyanshuai
-- -----------------------------------------------------------------------------
--]]

local AbilitySystem = require('System/Ability/AbilitySystem')
local TagUtil = require("System/Ability/Tag/TagUtil")
local AbilityPart = require('System/Ability/Part/AbilityPart')
local AttrDef = require("System/Ability/Attr/AttrDef")
local log = require('Core/Log/log') ---@as log
local assert = _G.assert

local testlog = function(...)
    log.log(...)
end

AbilitySystem.Get():InitAbilitySystem()

if true then
    local tag = TagUtil.RequestTag('skill.type.active')
    local container = TagUtil.MakeContainer()
    assert(container:HasTag(tag) == false)
    container:AddTag(tag)
    assert(container:HasTag(tag) == true)
    container:AddTag(tag)
    assert(container:HasTag(tag) == true)
    container:RemoveTag(tag)
    assert(container:HasTag(tag) == true)
    container:RemoveTag(tag)
    assert(container:HasTag(tag) == false)
end

if true then
    local attrMgr = AbilitySystem.Get():GetAttrManager()
    local set = attrMgr:CreateAttrSet({"Health"}) ---@type AttrSetClass

    local mod_baseHealth_add_10 = attrMgr:AcquireModifier(AttrDef.Attr.BaseHealth, 10)
    assert(mod_baseHealth_add_10.ModValue == 10 and mod_baseHealth_add_10.ModAttrKey == AttrDef.Attr.BaseHealth)
    set:AddModifier(mod_baseHealth_add_10)
    assert(set:GetAttrValue(AttrDef.Attr.BaseHealth) == 10)
    assert(set:GetAttrValue(AttrDef.Attr.MaxHealth) == 10)

    local mod_FlatHealth_add_10 = attrMgr:AcquireModifier(AttrDef.Attr.FlatHealth, 10)
    assert(mod_FlatHealth_add_10.ModValue == 10 and mod_FlatHealth_add_10.ModAttrKey == AttrDef.Attr.FlatHealth)
    set:AddModifier(mod_FlatHealth_add_10)
    assert(set:IsDirty(AttrDef.Attr.MaxHealth) == true)
    assert(set:GetAttrValue(AttrDef.Attr.FlatHealth) == 10)
    assert(set:GetAttrValue(AttrDef.Attr.MaxHealth) == 110)
    
    set:RemoveModifier(mod_baseHealth_add_10)
    assert(set:GetAttrValue(AttrDef.Attr.BaseHealth) == 0)
    assert(set:GetAttrValue(AttrDef.Attr.MaxHealth) == 100)

    local mod_perH_add_10 = attrMgr:AcquireModifier(AttrDef.Attr.PercentHealth, 10)
    set:AddModifier(mod_perH_add_10)
    assert(set:GetAttrValue(AttrDef.Attr.PercentHealth) == 10)
    assert(math.floor(set:GetAttrValue(AttrDef.Attr.MaxHealth)) == 110)
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