
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
---@field _Owner any
---@field _SkillTagContainer TagContainer
---@field _SlotInfos table<number, string[]> (SlotTag:AbilityKey[])
---@field _AbilityInfos table<string, AbilityClass> (AbilityKey:AbilityClass)
---@field _RefAbilityToSlots table<string, string[]> (AbilityKey:number[])
local AbilityPartClass = Class3.Class('AbilityPartClass')

---@public
function AbilityPartClass:Ctor(InOwner)
    self._Owner = InOwner
    self._SkillTagContainer = TagUtil.MakeContainer()

    self._SlotInfos = {}
    self._AbilityInfos = {}
    self._RefAbilityToSlots = {}

end

---@public
function AbilityPartClass:InitAbilitySlot()
end

---@public
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

---@public
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

---@public
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

---@public
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

---@public
---@param InAbilityKey string
---@return AbilityClass?
function AbilityPartClass:GetAbilityByKey(InAbilityKey)
    return self._AbilityInfos[InAbilityKey]
end

---@public
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

return AbilityPartClass