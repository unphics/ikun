
--[[
-- -----------------------------------------------------------------------------
--  Brief       : 能力系统-增益-增益实例
--  File        : Buff.lua
--  Author      : zhengyanshuai
--  Date        : Tue Feb 10 2026 11:19:32 GMT+0800 (中国标准时间)
--  Description : 增益是能力系统中的一种特殊能力，它可以临时修改角色的属性，或者添加/移除标签。
--  License     : MIT License
-- -----------------------------------------------------------------------------
--  Copyright (c) 2026 zhengyanshuai
-- -----------------------------------------------------------------------------
--]]


local Class3 = require('Core/Class/Class3')
local TagUtil = require('System/Ability/Tag/TagUtil')
local BuffPolicyDef = require('System/Ability/Buff/BuffPolicyDef')

---@class BuffConfig
---@field public BuffKey string
---@field public BuffName string
---@field public BuffPolicy BuffPolicyDef
---@field public BuffDuration number
---@field public Period number
---@field public GrantedTags number[]        -- TagId[]
---@field public BlockTags number[]          -- TagId[]
---@field public CancelTags number[]         -- TagId[]

---@class BuffBaseClass
---@field public BuffKey string
---@field public BuffName string
---@field public BuffPolicy BuffPolicyDef
---@field public BuffDuration number
---@field public Period number
---@field public GrantedTags number[]        -- TagId[]
---@field public BlockTags number[]          -- TagId[]
---@field public CancelTags number[]         -- TagId[]
---@field public BuffConfig BuffConfig
---@field public BuffSource AbilityPartClass
---@field public BuffTarget AbilityPartClass
---@field protected _StartTime number
---@field protected _EndTime number
local BuffBaseClass = Class3.Class('BuffBaseClass')

---@public
function BuffBaseClass:Ctor(spec)
    self.BuffKey = spec.Key
    self.BuffName = spec.BuffName
    self.BuffPolicy = spec.BuffPolicy or BuffPolicyDef.Instant
    self.BuffDuration = spec.BuffDuration or 0
    self.Period = spec.Period or 0
    self.GrantedTags = spec.GrantedTags or {}
    self.BlockTags = spec.BlockTags or {}
    self.CancelTags = spec.CancelTags or {}
    self._StartTime = 0
    self._EndTime = 0
end

---@public
---@return boolean
function BuffBaseClass:CanApplyBuff()
    local buffSource = self.BuffSource
    local buffTarget = self.BuffTarget
    -- Block
    if self.BlockTags and #self.BlockTags > 0 then
        local target = buffTarget ---@type AbilityPartClass
        if target and target:HasAnyTags(self.BlockTags) then
            return false
        end
    end
    -- Cancel 由 BuffManager 统一处理（互斥组/CancelTags）
    return true
end

---@public
---@param InTarget AbilityPartClass
---@param InSource AbilityPartClass
---@param InNowMS number
function BuffBaseClass:ApplyBuff(InTarget, InSource, InNowMS)
    self.BuffTarget = InTarget
    self.BuffSource = InSource
    self._StartTime = InNowMS
    if self.BuffPolicy == BuffPolicyDef.HasDuration then
        self._EndTime = self._StartTime + self.BuffDuration
    else
        self._EndTime = math.huge
    end
    -- GrantedTags
    for i = 1, #self.GrantedTags do
        self.BuffTarget:AddTag(self.GrantedTags[i])
    end
end

---@public
---@param InDeltaTime number
function BuffBaseClass:TickBuff(InDeltaTime)
end

---@public
function BuffBaseClass:DeactivateBuff()
    -- 移除 GrantedTags
    if self.BuffTarget then
        for i = 1, #self.GrantedTags do
            self.BuffTarget:RemoveTag(self.GrantedTags[i])
        end
    end
end

---@public
function BuffBaseClass:ReapplyBuff(InNowMS)
end

---@public 判断是否过期
---@param InNowMS number
---@return boolean
function BuffBaseClass:IsBuffExpired(InNowMS)
    return (self.BuffPolicy ~= BuffPolicyDef.Infinite) and (InNowMS >= self._EndTime)
end

return BuffBaseClass
