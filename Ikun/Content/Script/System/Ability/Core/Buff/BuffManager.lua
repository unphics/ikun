
--[[
-- -----------------------------------------------------------------------------
--  Brief       : 能力系统-增益-增益管理器
--  File        : BuffManager.lua
--  Author      : zhengyanshuai
--  Date        : Tue Feb 10 2026 14:19:55 GMT+0800 (中国标准时间)
--  Description : 负责增益的生命周期管理, 统一调度, "规则执行", 归档与查询
--  License     : MIT License
-- -----------------------------------------------------------------------------
--  Copyright (c) 2026 zhengyanshuai
-- -----------------------------------------------------------------------------
--]]

local Class3 = require('Core/Class/Class3')
local TagUtil = require('System/Ability/Core/Tag/TagUtil')

---@class BuffManager
---@field protected _System AbilitySystem
---@field _Active table<any, table<string, Buff>> -- Target -> Key -> Buff
local BuffManager = Class3.Class('BuffManager')

---@public
---@param InSystem AbilitySystem
function BuffManager:Ctor(InSystem)
    self._System = InSystem
    self._Active = {}
end

---@public
function BuffManager:InitBuffManager()
end

---@public
---@return number
function BuffManager:GetNowMS()
    return self._System:GetNowMS()
end

local function ensureTargetTable(self, target)
    local t = self._Active[target]
    if not t then
        t = {}
        self._Active[target] = t
    end
    return t
end

-- 互斥 / CancelTags：在施加前根据目标现有 Buff 的 Tag 进行取消
local function applyCancelByTags(self, target, cancelTags)
    if not cancelTags or #cancelTags == 0 then return end
    local tBuffs = self._Active[target]
    if not tBuffs then return end
    for _, buff in pairs(tBuffs) do
        local cont = target.TagContainer
        if cont then
            for i = 1, #cancelTags do
                if cont:HasTag(cancelTags[i]) then
                    self:RemoveBuff(target, buff.BuffKey)
                    break
                end
            end
        end
    end
end

---@public
---@param InTarget AbilityPartClass
---@param InSource AbilityPartClass
---@param InBuffInst BuffClass
function BuffManager:AddOrRefreshBuff(InTarget, InSource, InBuffInst)
    local now = self:GetNowMS()
    -- Block 检查
    local ok = InBuffInst:CanApplyBuff(InTarget, InSource)
    if not ok then
        return false
    end
    -- Cancel 检查
    applyCancelByTags(self, target, buff.CancelTags)

    local tBuffs = ensureTargetTable(self, target)
    local exist = tBuffs[buff.BuffKey]
    if exist then
        exist:RefreshBuff(now)
    else
        tBuffs[buff.BuffKey] = buff
        buff:Apply(self, target, source, now)
    end
    return true
end

function BuffManager:RemoveBuff(target, buffKey)
    local tBuffs = self._Active[target]
    if not tBuffs then return end
    local b = tBuffs[buffKey]
    if not b then return end
    b:Deactivate(self)
    tBuffs[buffKey] = nil
end

---@public
---@param InDeltaTime number
function BuffManager:TickBuffManager(InDeltaTime)
    local now = self:GetNowMS()
    local allBuffs = {} ---@type BuffClass[]
    for i = 1, #allBuffs do
        local buff = allBuffs[i]
        if buff:IsBuffExpired(now) then
            self:RemoveBuff(buff.Target, buff.BuffKey)
        else
            buff:TickBuff(InDeltaTime)
        end
    end
end

return BuffManager
