
--[[
-- -----------------------------------------------------------------------------
--  Brief       : 能力系统-增益-增益容器
--  File        : BuffContainer.lua
--  Author      : zhengyanshuai
--  Date        : Wed Feb 11 2026 21:32:02 GMT+0800 (中国标准时间)
--  Description : 增益容器
--  License     : MIT License
-- -----------------------------------------------------------------------------
--  Copyright (c) 2026 zhengyanshuai
-- -----------------------------------------------------------------------------
--]]

local Class3 = require("Core/Class/Class3")
local TimeLib = require("Core/TimeLib")
local Delegate = require("Core/Delegate")
local TableUtils = require("Core/Utils/TableUtils")

---@class BuffContainerClass
---@deprecated
---@field protected _OwnerPart AbilityPartClass
---@field protected _Buffs BuffBaseClass[]
---@field protected _OnBuffChanged Delegate
local BuffContainerClass = Class3.Class("BuffBaseClass")

---@public
---@param InBuffManager BuffManager
---@param InPart AbilityPartClass
function BuffContainerClass:Ctor(InBuffManager, InPart)
    self._BuffManager = InBuffManager
    self._OwnerPart = InPart
    self._OnBuffChanged = Delegate:New()
    self._Buffs = {}
end

---@public [Tick]
---@param InDeltaTime number
---@param InTimestampSec number
function BuffContainerClass:TickBuffContainer(InDeltaTime, InTimestampSec)
    for i = 1, #self._Buffs do
        local buff = self._Buffs[i]
        if buff:IsBuffExpired(InTimestampSec) then
            self:RemoveBuff(buff)
        else
            buff:TickBuff(InDeltaTime, InTimestampSec)
        end
    end
end

---@public
---@param InBuffInst BuffBaseClass
function BuffContainerClass:AddBuff(InBuffInst)
    InBuffInst:ApplyBuff(TimeLib.GetTimestampSec())
    table.insert(self._Buffs, InBuffInst)
    self:GetOnBuffChangedDelegate():BroadcastCallback()
end

---@public
---@param InBuffInst BuffBaseClass
function BuffContainerClass:RemoveBuff(InBuffInst)
    for i = 1, #self._Buffs do
        local buff = self._Buffs[i]
        if buff == InBuffInst then
            InBuffInst:DeactivateBuff()
            table.remove(self._Buffs, i)
            self:GetOnBuffChangedDelegate():BroadcastCallback()
            break
        end
    end
end

---@public
---@return Delegate
function BuffContainerClass:GetOnBuffChangedDelegate() -- const
    return self._OnBuffChanged
end

---@public
function BuffContainerClass:GetAllBuffs()
    return TableUtils.ShallowCopy(self._Buffs)
end

return BuffContainerClass