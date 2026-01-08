
--[[
-- -----------------------------------------------------------------------------
--  Brief       : SkillPartClass
--  File        : SkillPart.lua
--  Author      : zhengyanshuai
--  Date        : Sat Jan 03 2026 16:06:37 GMT+0800 (中国标准时间)
--  Description : 技能系统-技能部件
--  License     : MIT License
-- -----------------------------------------------------------------------------
--  Copyright (c) 2026 zhengyanshuai
-- -----------------------------------------------------------------------------
--]]

local Class3 = require('Core/Class/Class3')
local SkillSystem = require('System/Skill/SkillSystem')
local ArmsClass = require('System/Skill/Core/Skill/Arms')
local TagUtil = require("System/Skill/Core/Tag/TagUtil")
local log = require('Core/Log/log')

---@class SkillPartClass
---@field _Owner any
---@field _SkillTagContainer TagContainer
---@field _SlotInfos table<number, string[]> (SlotTag:ArmsKey[])
---@field _ArmsInfos table<string, ArmsClass> (ArmsKey:ArmsClass)
---@field _RefArmsToSlots table<string, string[]> (ArmsKey:number[])
local SkillPartClass = Class3.Class('SkillPartClass')

---@public
function SkillPartClass:Ctor(InOwner)
    self._Owner = InOwner
    self._SkillTagContainer = TagUtil.MakeContainer()

    self._SlotInfos = {}
    self._ArmsInfos = {}
    self._RefArmsToSlots = {}

end

---@public
function SkillPartClass:InitArmsSlot()
end

---@public
---@param InArmsKey string
---@param InSlotTag number
function SkillPartClass:AddArmsToSlot(InArmsKey, InSlotTag)
    local skillManager = SkillSystem.Get():GetSkillManager()
    local config = skillManager:LookupArmsConfig(InArmsKey)
    if not config then
        log.warn('SkillPartClass:AddArmsToSlot(): Invalid InArmsKey')
        return
    end

    if not self._SlotInfos[InSlotTag] then
        self._SlotInfos[InSlotTag] = {}
    end
    
    if not self._ArmsInfos[InArmsKey] then
        local arms = ArmsClass:New(skillManager, InArmsKey) ---@type ArmsClass
        self._ArmsInfos[InArmsKey] = arms
    end
    
    table_util.add_unique(self._SlotInfos[InSlotTag], InArmsKey)

    if not self._RefArmsToSlots[InArmsKey] then
        self._RefArmsToSlots[InArmsKey] = {}
    end
    table.insert(self._RefArmsToSlots[InArmsKey], InSlotTag)
end

---@public
---@param InArmsKey string
---@param InSlotTag number
function SkillPartClass:RemoveArmsFromSlot(InArmsKey, InSlotTag)
    local slots = self._RefArmsToSlots[InArmsKey]
    if not slots or #slots < 1 then
        return
    end

    local slot = self._SlotInfos[InSlotTag]
    ---@param InItem string
    if table_util.remove_if(slot, function (InItem) return InItem == InArmsKey end) then
        table_util.remove_if(slots, function (InItem) return InItem == InArmsKey end)
    end

    if #slots < 1 then
        self._ArmsInfos[InArmsKey] = nil
    end
end

---@public
---@param InArmsKey string
function SkillPartClass:RemoveArmsByKey(InArmsKey)
    local slots = self._RefArmsToSlots[InArmsKey]
    if not slots or #slots < 1 then
        return
    end

    self._ArmsInfos[InArmsKey] = nil
    
    for i = 1, #slots do
        local slotName = slots[i]
        local slot = self._SlotInfos[slotName]
        ---@param InItem string
        table_util.remove_if(slot, function (InItem) return InItem == InArmsKey end)
    end
end

---@public
---@param InSlotTag number
---@return ArmsClass[]
function SkillPartClass:GetSlotArms(InSlotTag)
    local slot = self._SlotInfos[InSlotTag] or {}
    local tbArms = {}
    for i = 1, #slot do
        local arms = self:GetArmsByKey(slot[i])
        if arms then
            table.insert(tbArms, arms)
        end
    end
    return tbArms
end

---@public
---@param InArmsKey string
---@return ArmsClass?
function SkillPartClass:GetArmsByKey(InArmsKey)
    return self._ArmsInfos[InArmsKey]
end

---@public
---@param InArmsKey string
---@param Params table
---@return boolean
function SkillPartClass:UseArms(InArmsKey, Params)
    local arms = self._ArmsInfos[InArmsKey] ---@type ArmsClass
    if not arms then
        return false
    end

    if not arms:CanUse(Params) then
        return false
    end

    arms:UseSkill(Params)
    return true
end

return SkillPartClass