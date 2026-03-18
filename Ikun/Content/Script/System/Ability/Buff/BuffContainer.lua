
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
local Time = require("Core/Time")

---@class BuffContainerClass
---@deprecated
---@field protected _OwnerPart AbilityPartClass
---@field protected _Buffs BuffBaseClass[]
local BuffContainerClass = Class3.Class("BuffBaseClass")

---@public
---@param InBuffManager BuffManager
---@param InPart AbilityPartClass
function BuffContainerClass:Ctor(InBuffManager, InPart)
    self._BuffManager = InBuffManager
    self._OwnerPart = InPart
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
    InBuffInst:ApplyBuff(Time.GetTimestampSec())
    table.insert(self._Buffs, InBuffInst)
end

---@public
---@param InBuffInst BuffBaseClass
function BuffContainerClass:RemoveBuff(InBuffInst)
    for i = 1, #self._Buffs do
        local buff = self._Buffs[i]
        if buff == InBuffInst then
            InBuffInst:DeactivateBuff()
            table.remove(self._Buffs, i)
            break
        end
    end
end

return BuffContainerClass