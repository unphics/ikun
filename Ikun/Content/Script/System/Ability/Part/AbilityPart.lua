
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

local Class3 = require("Core/Class/Class3")
local AbilitySystem = require("System/Ability/AbilitySystem")
local AbilityClass = require("System/Ability/Ability/Ability")
local BuffBaseClass = require("System/Ability/Buff/BuffBase")
local TagUtil = require("System/Ability/Tag/TagUtil")
local BuffContainer = require("System/Ability/Buff/BuffContainer")
local log = require("Core/Log/log")

---@class AbilityPartClass
---@field protected _Owner RoleBaseClass
---@field protected _AttrSet AttrSetClass
---@field protected _PartTagContainer TagContainer
---@field protected _SlotInfos table<number, string[]> (SlotTag:AbilityKey[])
---@field protected _AbilityInfos table<string, AbilityClass> (AbilityKey:AbilityClass)
---@field protected _RefAbilityToSlots table<string, string[]> (AbilityKey:number[])
local AbilityPartClass = Class3.Class("AbilityPartClass")

---@public
function AbilityPartClass:Ctor(InOwner)
    self._Owner = InOwner
    self._PartTagContainer = TagUtil.MakeContainer()
    self._BuffContainer = AbilitySystem.Get():GetBuffManager():AcquireBuffContainer()

    self._SlotInfos = {}
    self._AbilityInfos = {}
    self._RefAbilityToSlots = {}
end

---@public [AttrSet]
---@param InAttrSetConfig string[]
function AbilityPartClass:InitAttrSet(InAttrSetConfig)
    local mgr = AbilitySystem.Get():GetAttrManager()
    local set = mgr:CreateAttrSet(InAttrSetConfig)
    self._AttrSet = set
end

---@public [AttrSet]
---@return AttrSetClass
function AbilityPartClass:GetAttrSet()
    return self._AttrSet
end

---@public [Ability]
---@param InAbilitySlotInfo table<string, string>
function AbilityPartClass:InitAbilitySlot(InAbilitySlotInfo)
    for tagName, abilityKey in pairs(InAbilitySlotInfo) do
        local slot = TagUtil.RequestTag("Ability.Slot."..tagName)
        if not slot then
            log.error_fmt("AbilityPartClass:InitAbilitySlot(): InValid tag, name = [%s]", string(tagName))
            goto continue
        end
        self:AddAbilityToSlot(slot, abilityKey)
        ::continue::
    end
end

---@public [Ability]
---@param InAbilityKey string
---@param InSlotTag number
function AbilityPartClass:AddAbilityToSlot(InSlotTag, InAbilityKey)
    if not self._SlotInfos[InSlotTag] then
        self._SlotInfos[InSlotTag] = {}
    end
    if not self._AbilityInfos[InAbilityKey] then
        local mgr = AbilitySystem.Get():GetAbilityManager()
        local ability = mgr:CreateAbility(InAbilityKey, self)
        if ability then
            self._AbilityInfos[InAbilityKey] = ability
        end
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
        local slot = self._SlotInfos[slotName] ---@type table<number, string>
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

---@public
---@param InBuffKey string
---@return BuffBaseClass?
function AbilityPartClass:MakeBuff(InBuffKey)
    local mgr = AbilitySystem.Get():GetBuffManager()
    local buff = mgr:CreateBuff(InBuffKey)
    if buff then
        buff.BuffSource = self
    end
    return buff
end

---@public [Buff]
---@param InBuffInst BuffBaseClass
function AbilityPartClass:ApplyBuffToSelf(InBuffInst)
    InBuffInst.BuffTarget = self
    local ok = InBuffInst:CanApplyBuff()
    if not ok then
        return
    end
    self._BuffContainer:AddBuff(InBuffInst)
end

return AbilityPartClass
