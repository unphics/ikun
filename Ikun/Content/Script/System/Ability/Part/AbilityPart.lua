
--[[
-- -----------------------------------------------------------------------------
--  Brief       : AbilityPartClass
--  File        : AbilityPart.lua
--  Author      : zhengyanshuai
--  Date        : Sat Jan 03 2026 16:06:37 GMT+0800 (中国标准时间)
--  Description : 能力系统-技能部件
--  Todo        : 把Slot相关的挪到AP的derive中, 留一个业务无关的AP
--  License     : MIT License
-- -----------------------------------------------------------------------------
--  Copyright (c) 2026 zhengyanshuai
-- -----------------------------------------------------------------------------
--]]

local Class3 = require("Core/Class/Class3")
local AbilitySystem = require("System/Ability/AbilitySystem")
local AbilityClass = require("System/Ability/Ability/Ability")
local TagUtils = require("System/Ability/Tag/TagUtils")
local EffectorContainerClass = require("System/Ability/Effect/EffectorContainer")
local log = require("Core/Log/log")

---@class AbilityPartClass
---@field protected _Owner RoleBaseClass
---@field protected _AttrSet AttrSetClass
---@field protected _PartTagContainer TagContainer
---@field protected _SlotInfos table<number, string[]> (SlotTag:AbilityKey[])
---@field protected _AbilityInfos table<string, AbilityClass> (AbilityKey:AbilityClass)
---@field protected _RefAbilityToSlots table<string, string[]> (AbilityKey:number[])
---@field protected _EffectorContainer EffectorContainerClass
local AbilityPartClass = Class3.Class("AbilityPartClass")

---@public
function AbilityPartClass:Ctor(InOwner)
    self._Owner = InOwner
    self._PartTagContainer = TagUtils.MakeContainer()
    self._EffectorContainer = EffectorContainerClass:New(AbilitySystem.Get():GetEffectManager(), self)

    self._SlotInfos = {}
    self._AbilityInfos = {}
    self._RefAbilityToSlots = {}
end

---@public [AttrSet]
---@param InAttrSetConfig string[]
---@param InAttrSetClass? AttrSetClass
function AbilityPartClass:InitAttrSet(InAttrSetConfig, InAttrSetClass)
    local mgr = AbilitySystem.Get():GetAttrManager()
    local set = mgr:CreateAttrSet(InAttrSetConfig, InAttrSetClass)
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
        local slot = TagUtils.RequestTag("Ability.Slot."..tagName)
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

    if not ability:CanCast(Params) then
        return false
    end

    ability:CastSkill(Params)
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

---@public [Effect]
---@return EffectorBaseClass?
function AbilityPartClass:MakeEffector(InEffectorKey)
    local effector = AbilitySystem.Get():GetEffectManager():CreateEffector(InEffectorKey)
    if not effector then
        return
    end

    effector.EffectorSource = self
    effector:InitEffector()
    return effector
end

---@public [Effect]
---@param InEffectorInst EffectorBaseClass
function AbilityPartClass:TryApplyEffectorToSelf(InEffectorInst)
    InEffectorInst.EffectorTarget = self
    if not InEffectorInst:CanActiveEffector() then
        return
    end
    self._EffectorContainer:AddEffector(InEffectorInst)
end

---@public
function AbilityPartClass:GetOwnerRole() -- const
    return self._Owner
end

return AbilityPartClass