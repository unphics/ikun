
--[[
-- -----------------------------------------------------------------------------
--  Brief       : 能力系统-增益
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
local TagUtil = require('System/Ability/Core/Tag/TagUtil')
local BuffPolicyDef = require('System/Ability/Core/Buff/BuffPolicyDef')

---@class BuffClass
---@field public BuffKey string
---@field public BuffName string
---@field public BuffPolicy number
---@field public BuffDuration number
---@field public Period number
---@field public GrantedTags number[]        -- TagId[]
---@field public BlockTags number[]          -- TagId[]
---@field public CancelTags number[]         -- TagId[]
---@field protected _StartTime number
---@field protected _EndTime number
---@field NextTickTime number
---@field StackCount number
---@field MaxStacks number
---@field Source any
---@field Target any
---@field Context table
local BuffClass = Class3.Class('BuffClass')

function BuffClass:Ctor(spec)
    self.BuffKey = spec.Key
    self.BuffName = spec.BuffName
    self.BuffPolicy = spec.BuffPolicy or BuffPolicyDef.Instant
    self.BuffDuration = spec.BuffDuration or 0
    self.Period = spec.Period or 0
    self.StackCount = spec.StackCount or 1
    self.MaxStacks = spec.MaxStacks or 1
    self.GrantedTags = spec.GrantedTags or {}
    self.BlockTags = spec.BlockTags or {}
    self.CancelTags = spec.CancelTags or {}
    self._StartTime = 0
    self._EndTime = 0
    self.NextTickTime = 0
end

-- 可覆写
function BuffClass:OnActive(sys, target, source, ctx) end
function BuffClass:OnRefresh(sys, target, source, ctx) end
function BuffClass:OnDeactivate(sys, target, source, ctx) end
function BuffClass:OnTick(sys, target, source, ctx, dt) end

local function hasAnyTag(container, tags)
    for i = 1, #tags do
        if container:HasTag(tags[i]) then
            return true
        end
    end
    return false
end

function BuffClass:TryApply(sys, target, source, ctx)
    -- Block
    if self.BlockTags and #self.BlockTags > 0 then
        local tCont = target.TagContainer
        if tCont and hasAnyTag(tCont, self.BlockTags) then
            return false, 'BlockedByTag'
        end
    end
    -- Cancel 由 BuffManager 统一处理（互斥组/CancelTags）
    return true
end

function BuffClass:Apply(sys, target, source, ctx, now)
    self.Source, self.Target, self.Context = source, target, ctx
    self._StartTime = now or sys:Now()
    if self.BuffPolicy == BuffPolicyDef.HasDuration then
        self._EndTime = self._StartTime + self.BuffDuration
    else
        self._EndTime = math.huge
    end
    -- GrantedTags
    local tCont = target.TagContainer
    if tCont then
        for i = 1, #self.GrantedTags do
            tCont:AddTag(self.GrantedTags[i])
        end
    end
    -- Period
    self.NextTickTime = self.Period > 0 and (self._StartTime + self.Period) or math.huge
    self:OnActive(sys, target, source, ctx)
end

function BuffClass:Refresh(sys, target, source, ctx, now)
    -- 默认：叠层（不超过上限），重置持续时间
    self.StackCount = math.min(self.StackCount + 1, self.MaxStacks)
    if self.BuffPolicy == BuffPolicyDef.HasDuration then
        self._StartTime = now or sys:Now()
        self._EndTime = self._StartTime + self.BuffDuration
        self.NextTickTime = self.Period > 0 and (self._StartTime + self.Period) or math.huge
    end
    self:OnRefresh(sys, target, source, ctx)
end

function BuffClass:IsExpired(now)
    return self.BuffPolicy ~= BuffPolicyDef.Infinite and now >= self._EndTime
end

function BuffClass:Tick(sys, dt, now)
    if self.Period > 0 and now >= self.NextTickTime then
        self:OnTick(sys, self.Target, self.Source, self.Context, dt)
        self.NextTickTime = now + self.Period
    end
end

function BuffClass:Deactivate(sys)
    -- 移除 GrantedTags
    local tCont = self.Target and self.Target.TagContainer
    if tCont then
        for i = 1, #self.GrantedTags do
            tCont:RemoveTag(self.GrantedTags[i])
        end
    end
    self:OnDeactivate(sys, self.Target, self.Source, self.Context)
end

return BuffClass