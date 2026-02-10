
--[[
-- -----------------------------------------------------------------------------
--  Brief       : AbilityPartClass
--  File        : AbilityPart.lua
--  Author      : zhengyanshuai
--  Date        : Sat Jan 03 2026 16:06:37 GMT+0800 (中国标准时间)
--  Description : 能力系统-技能部件
--  License     : MIT License
-- -----------------------------------------------------------------------------
--  Copyright (c) 2026 zhengyanshuai
-- -----------------------------------------------------------------------------
--]]

local Class3 = require('Core/Class/Class3')
local AbilitySystem = require('System/Ability/AbilitySystem')
local AbilityClass = require('System/Ability/Core/Ability/Ability')
local TagUtil = require("System/Ability/Core/Tag/TagUtil")
local log = require('Core/Log/log')

---@class AbilityPartClass
---@field protected _Owner any
---@field protected _ActivedBuffs BuffClass[]
---@field protected _PartTagContainer TagContainer
---@field protected _SlotInfos table<number, string[]> (SlotTag:AbilityKey[])
---@field protected _AbilityInfos table<string, AbilityClass> (AbilityKey:AbilityClass)
---@field protected _RefAbilityToSlots table<string, string[]> (AbilityKey:number[])
local AbilityPartClass = Class3.Class('AbilityPartClass')

---@public
function AbilityPartClass:Ctor(InOwner)
    self._Owner = InOwner
    self._PartTagContainer = TagUtil.MakeContainer()

    self._SlotInfos = {}
    self._AbilityInfos = {}
    self._RefAbilityToSlots = {}
end

---@public [Ability]
function AbilityPartClass:InitAbilitySlot()
end

---@public [Ability]
---@param InAbilityKey string
---@param InSlotTag number
function AbilityPartClass:AddAbilityToSlot(InAbilityKey, InSlotTag)
    local AbilityManager = AbilitySystem.Get():GetAbilityManager()
    local config = AbilityManager:LookupAbilityConfig(InAbilityKey)
    if not config then
        log.warn('AbilityPartClass:AddAbilityToSlot(): Invalid InAbilityKey')
        return
    end

    if not self._SlotInfos[InSlotTag] then
        self._SlotInfos[InSlotTag] = {}
    end
    
    if not self._AbilityInfos[InAbilityKey] then
        local ability = AbilityClass:New(AbilityManager, InAbilityKey) ---@type AbilityClass
        self._AbilityInfos[InAbilityKey] = ability
    end
    
    table_util.add_unique(self._SlotInfos[InSlotTag], InAbilityKey)

    if not self._RefAbilityToSlots[InAbilityKey] then
        self._RefAbilityToSlots[InAbilityKey] = {}
    end
    table.insert(self._RefAbilityToSlots[InAbilityKey], InSlotTag)
end

---@public [Ability]
---@param InAbilityKey string
---@param InSlotTag number
function AbilityPartClass:RemoveAbilityFromSlot(InAbilityKey, InSlotTag)
    local slots = self._RefAbilityToSlots[InAbilityKey]
    if not slots or #slots < 1 then
        return
    end

    local slot = self._SlotInfos[InSlotTag]
    ---@param InItem string
    if table_util.remove_if(slot, function (InItem) return InItem == InAbilityKey end) then
        table_util.remove_if(slots, function (InItem) return InItem == InAbilityKey end)
    end

    if #slots < 1 then
        self._AbilityInfos[InAbilityKey] = nil
    end
end

---@public [Ability]
---@param InAbilityKey string
function AbilityPartClass:RemoveAbilityByKey(InAbilityKey)
    local slots = self._RefAbilityToSlots[InAbilityKey]
    if not slots or #slots < 1 then
        return
    end

    self._AbilityInfos[InAbilityKey] = nil
    
    for i = 1, #slots do
        local slotName = slots[i]
        local slot = self._SlotInfos[slotName]
        ---@param InItem string
        table_util.remove_if(slot, function (InItem) return InItem == InAbilityKey end)
    end
end

---@public [Ability]
---@param InSlotTag number
---@return AbilityClass[]
function AbilityPartClass:GetSlotAbility(InSlotTag)
    local slot = self._SlotInfos[InSlotTag] or {}
    local tbAbility = {}
    for i = 1, #slot do
        local ability = self:GetAbilityByKey(slot[i])
        if ability then
            table.insert(tbAbility, ability)
        end
    end
    return tbAbility
end

---@public [Ability]
---@param InAbilityKey string
---@return AbilityClass?
function AbilityPartClass:GetAbilityByKey(InAbilityKey)
    return self._AbilityInfos[InAbilityKey]
end

---@public [Ability]
---@param InAbilityKey string
---@param Params table
---@return boolean
function AbilityPartClass:UseAbility(InAbilityKey, Params)
    local ability = self._AbilityInfos[InAbilityKey] ---@type AbilityClass
    if not ability then
        return false
    end

    if not ability:CanUse(Params) then
        return false
    end

    ability:UseSkill(Params)
    return true
end

---@public [Tag]
---@param InTag number
function AbilityPartClass:AddTag(InTag)
    self._PartTagContainer:AddTag(InTag)
end

---@public [Tag]
---@param InTag number
function AbilityPartClass:RemoveTag(InTag)
    self._PartTagContainer:RemoveTag(InTag)
end

---@public [Tag]
---@param InTag number
function AbilityPartClass:HasTag(InTag)
    return self._PartTagContainer:HasTag(InTag)
end

---@public [Tag]
---@param InTags number[]
function AbilityPartClass:HasAnyTags(InTags)
    return self._PartTagContainer:HasAnyTags(InTags)
end

---@public [Buff]
---@param InBuffKey string
function AbilityPartClass:TryApplyBuff(InBuffKey)
    local BuffManager = AbilitySystem.Get():GetBuffManager()
    local buff = BuffManager:LookupBuffConfig(InBuffKey)
    if not buff then
        log.warn('AbilityPartClass:TryApplyBuff(): Invalid InBuffKey')
        return false
    end
    
end

return AbilityPartClass