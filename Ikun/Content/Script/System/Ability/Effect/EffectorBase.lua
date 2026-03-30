
--[[
-- -----------------------------------------------------------------------------
--  Brief       : 能力系统-效果-效果器
--  File        : EffectorBaseClass.lua
--  Author      : zhengyanshuai
--  Date        : Mon Mar 16 2026 16:31:18 GMT+0800 (中国标准时间)
--  Description : 效果器
--  License     : MIT License
-- -----------------------------------------------------------------------------
--  Copyright (c) 2026 zhengyanshuai
-- -----------------------------------------------------------------------------
--]]

local Class3 = require("Core/Class/Class3")
local AttrInteractContextClass = require("System/Ability/Attr/AttrInteractContext")

---@class EffectorBaseClass
---@field protected _Manager EffectManager
---@field protected _EffectConfig EffectorConfig
---@field protected _StartTime number
---@field protected _EndTime number
---@field protected _Duration number
---@field protected _Interval number
---@field protected _LastApplyTime number 上一次周期触发的时间戳
---@field protected _ActiveModifiers AttrModifierClass[]
---@field public EffectorSource AbilityPartClass
---@field public EffectorTarget AbilityPartClass
local EffectorBaseClass = Class3.Class('EffectorBaseClass')

---@public
function EffectorBaseClass:Ctor(InManager, InConfig)
    self._Manager = InManager
    self._EffectConfig = InConfig
end

---@public
function EffectorBaseClass:InitEffector()
    self._Duration = self:GetEffectorConfig().EffectDuration or -1
    self._Interval = self:GetEffectorConfig().EffectPeroid or -1
end

---@public
---@return boolean
function EffectorBaseClass:CanActiveEffector()
    local blockByRags = self:GetEffectorConfig().BlockByTags
    if blockByRags and #blockByRags > 0 then
        if self.EffectorTarget and self.EffectorTarget:HasAnyTags(blockByRags) then
            return false
        end
    end

    return true
end

---@public
function EffectorBaseClass:ActiveEffector(InTimestampSec)
    self._StartTime = InTimestampSec
    if self._Duration >= 0 then
        self._EndTime = self._StartTime + self._Duration
    else
        self._EndTime = math.huge
    end

    local grantedTags = self:GetEffectorConfig().GrantedTags
    if grantedTags then
        for i = 1, #grantedTags do
            self.EffectorTarget:AddTag(grantedTags[i])
        end
    end

    self._ActiveModifiers = {}

    if self._Interval >= 0 then
        self._LastApplyTime = self._StartTime
        self:ApplyEffector()
    else
        self._LastApplyTime = -1
    end

    self:OnActiveEffector(InTimestampSec)
end
---@public
function EffectorBaseClass:OnActiveEffector(InTimestampSec)
end

---@public
function EffectorBaseClass:InactiveEffector()
    self:OnInactiveEffector()

    local grantedTags = self:GetEffectorConfig().GrantedTags
    if grantedTags then
        for i = 1, #grantedTags do
            self.EffectorTarget:RemoveTag(grantedTags[i])
        end
    end

    local attrSet = self.EffectorTarget:GetAttrSet()
    for i = 1, #self._ActiveModifiers do
        attrSet:RemoveModifier(self._ActiveModifiers[i])
    end
    self._ActiveModifiers = {}
end

---@private
function EffectorBaseClass:OnInactiveEffector()
end

---@public
function EffectorBaseClass:TickEffector(InDeltaTime, InTimestampSec)
    if self._Interval > 0 and self._LastApplyTime then
        local nextApplyTime = self._LastApplyTime + self._Interval
        while InTimestampSec >= nextApplyTime do
            self:ApplyEffector()
            nextApplyTime = nextApplyTime + self._Interval
        end
        self._LastApplyTime = nextApplyTime - self._Interval -- 把多加以判断那个时间是否走了的未来时间剪掉
    end
end

---@private
function EffectorBaseClass:ApplyEffector()
    self:OnApplyEffector()
end
---@private
function EffectorBaseClass:OnApplyEffector()
end

---@public
function EffectorBaseClass:ReapplyEffector()
end

---@public 判断是否过期
---@return boolean
function EffectorBaseClass:IsEffectorExpried(InTimestampSec) -- const
    return self._Duration >= 0 and InTimestampSec >= self._EndTime
end

---@public
---@return EffectorConfig
function EffectorBaseClass:GetEffectorConfig()
    return self._EffectConfig
end

---@public
---@return AttrInteractContextClass
function EffectorBaseClass:MakeInteractContext()
    local ctx = AttrInteractContextClass:New(self) ---@type AttrInteractContextClass
    if not self._EffectConfig.AttrImposeFml then
        return ctx
    end
    local attr = self._EffectConfig.AttrImposeFml.AttrId
    ctx:SetImposeInfo(self.EffectorSource, self._EffectConfig.AttrImposeFml.Formula, attr)
    ctx:SetReceiveInfo(self.EffectorTarget, self._Manager:GetAbilitySystem():GetAttrManager():GetAttrReceiveFormula(attr))
    return ctx
end

---@public
---@param InInteractContext AttrInteractContextClass
---@return AttrModifierClass
function EffectorBaseClass:ApplyAttrInteract(InInteractContext)
    local attrManager = self._Manager:GetAbilitySystem():GetAttrManager()

    InInteractContext:CalcAttrImposeValue()
    InInteractContext:CalcAttrReceviveValue()

    local mod = attrManager:AcquireModifier(InInteractContext.InteractAttr, InInteractContext.ReceiveValue)
    self.EffectorTarget:GetAttrSet():AddModifier(mod)
    table.insert(self._ActiveModifiers, mod)

    return mod
end

return EffectorBaseClass