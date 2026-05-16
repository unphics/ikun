
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
local TagUtils = require("System/Ability/Tag/TagUtils")
local EffectorContainerClass = require("System/Ability/Effect/EffectorContainer")
local log = require("Core/Log/log")
local AttrFactoryClass = require("System/Ability/Attr/AttrFactory")
local EffectConfig = require("System/Ability/Effect/EffectConfig")
local EffectFactoryClass = require("System/Ability/Effect/EffectFactory")
local AbilityFactoryClass = require("System/Ability/Ability/AbilityFactory")
local AbilityContainerClass = require("System/Ability/Ability/AbilityContainer")
local BuffContainerClass = require("System/Ability/Buff/BuffContainer")

---@class AbilityPartClass
---@field protected _Owner RoleBaseClass
---@field protected _AttrSet AttrSetClass
---@field protected _PartTagContainer TagContainer
---@field protected _SlotInfos table<number, string[]> (SlotTag:AbilityKey[])
---@field protected _AbilityInfos table<string, AbilityBaseClass> (AbilityKey:AbilityBaseClass)
---@field protected _RefAbilityToSlots table<string, string[]> (AbilityKey:number[])
---@field protected _ActiveEffectorContainer EffectorContainerClass
---@field protected _ActiveAbilityContainer AbilityContainerClass
---@field protected _ActiveBuffContainer BuffContainerClass
local AbilityPartClass = Class3.Class("AbilityPartClass")

---@public
function AbilityPartClass:Ctor(InOwner)
    self._Owner = InOwner
    self._PartTagContainer = TagUtils.MakeContainer()
    self._ActiveEffectorContainer = EffectorContainerClass:New(AbilitySystem.Get():GetEffectManager(), self)
    self._ActiveAbilityContainer = AbilityContainerClass:New(self)
    self._ActiveBuffContainer = BuffContainerClass:New(self)

    self._SlotInfos = {}
    self._AbilityInfos = {}
    self._RefAbilityToSlots = {}
end

---@public
function AbilityPartClass:TickAbilityPart(InDeltaTime, InTimestampSec)
    self._ActiveEffectorContainer:TickEffectorContainer(InDeltaTime, InTimestampSec)
end

---@public [AttrSet]
function AbilityPartClass:InitAttrSet(InAttrSetConfig)
    self._AttrSet = AttrFactoryClass.Get():CreateAttrSet(InAttrSetConfig, self)
end

---@public [AttrSet]
---@return AttrSetClass
function AbilityPartClass:GetAttrSet()
    return self._AttrSet
end

---@public [Ability]
---@param InAbility AbilityBaseClass
function AbilityPartClass:AddAbility(InAbility)
    self._ActiveAbilityContainer:AddAbility(InAbility)
end

---@public [Ability]
---@param InAbility AbilityBaseClass
function AbilityPartClass:RemoveAbility(InAbility)
    self._ActiveAbilityContainer:RemoveAbility(InAbility)
end

---@public [Ability]
---@param InTag integer
---@return AbilityBaseClass[]
function AbilityPartClass:FindAbilitiesByTag(InTag)
    return self._ActiveAbilityContainer:FindAbilitiesByTag(InTag)
end

---@public [Ability]
---@param InAbilitiesKey string
---@return AbilityBaseClass[]
function AbilityPartClass:FindAbilitiesByKey(InAbilitiesKey)
    return self._ActiveAbilityContainer:FindAbilitiesByKey(InAbilitiesKey)
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
    local effector = EffectFactoryClass.Get():CreateEffector(InEffectorKey)
    if not effector then
        return
    end

    effector.EffectorSource = self
    effector:InitEffector()
    return effector
end

---@public [Effect]
---@param InEffectorInst EffectorBaseClass
function AbilityPartClass:ApplyEffectorToSelf(InEffectorInst)
    InEffectorInst.EffectorTarget = self
    if not InEffectorInst:CanActiveEffector() then
        return
    end
    self._ActiveEffectorContainer:AddEffector(InEffectorInst)
end

---@public [Buff]
---@param InBuffInst BuffBaseClass
function AbilityPartClass:ApplyBuffToSelf(InBuffInst)
    self._ActiveBuffContainer:AddBuff(InBuffInst)
end

---@public [Buff]
---@param InBuffInst BuffBaseClass
function AbilityPartClass:RemoveBuff(InBuffInst)
end

---@public [Buff]
function AbilityPartClass:RemoveBuffsByTag()
end

---@public [Buff]
function AbilityPartClass:FindBuffsByTag()
end

---@public [Buff]
function AbilityPartClass:GetAllBuffs()
end

---@public [Buff]
---@return Delegate
function AbilityPartClass:GetOnBuffChangedDelegate()
    return self._ActiveBuffContainer:GetOnBuffChangedDelegate()
end

---@public [Info]
function AbilityPartClass:GetOwnerRole() -- const
    return self._Owner
end

return AbilityPartClass