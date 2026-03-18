
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

local Class3 = require('Core/Class/Class3')

---@class EffectConfig
---@field EffectKey string
---@field EffectTemplate string 模板
---@field EffectPeroid integer 优先级
---@field EffectDuration number 持续时间
---@field EffectPriority number 周期
---@field AttrModFml string
---@field GrantedTags string[]
---@field BlockByTags string[]
---@field CancelToTags string[]

---@class EffectorBaseClass
---@field protected _Manager EffectManager
---@field protected _EffectConfig EffectConfig
---@field protected _StartTime number
---@field protected _EndTime number
---@field protected _Duration number
---@field protected _Interval number
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
    self._Duration = self:GetEffectorConfig().EffectDuration
    self._Interval = self:GetEffectorConfig().EffectPeroid
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
    for i = 1, #grantedTags do
        self.EffectorTarget:AddTag(grantedTags[i])
    end
end

---@public
function EffectorBaseClass:DeactiveEffector()
    local blockByRags = self:GetEffectorConfig().BlockByTags
    if self.EffectorTarget then
        for i = 1, #blockByRags do
            self.EffectorTarget:RemoveTag(blockByRags[i])
        end
    end
end

---@public
function EffectorBaseClass:TickEffector(InDeltaTime, InTimestampSec)
end

---@protected
function EffectorBaseClass:_ApplyEffector()
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
---@return EffectConfig
function EffectorBaseClass:GetEffectorConfig()
    return self._EffectConfig
end

return EffectorBaseClass