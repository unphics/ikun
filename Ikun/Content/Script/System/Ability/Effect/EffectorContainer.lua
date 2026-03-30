
--[[
-- -----------------------------------------------------------------------------
--  Brief       : 能力系统-增益-效果器容器
--  File        : EffectorContainer.lua
--  Author      : zhengyanshuai
--  Date        : Mon Mar 16 2026 22:33:19 GMT+0800 (中国标准时间)
--  Description : 效果器容器
--  License     : MIT License
-- -----------------------------------------------------------------------------
--  Copyright (c) 2026 zhengyanshuai
-- -----------------------------------------------------------------------------
--]]

local Class3 = require("Core/Class/Class3")
local log = require("Core/Log/log")

---@class EffectorContainerClass
---@field _EffectManager EffectManager
---@field _OwnerPart AbilityPartClass
---@field _Effectors EffectorBaseClass[]
local EffectorContainerClass = Class3.Class("EffectorContainerClass")

---@public
function EffectorContainerClass:Ctor(InEffectManager, InPart)
    self._EffectManager = InEffectManager
    self._OwnerPart = InPart

    self._Effectors = {}

    self._EffectManager:AddEffectorContainer(self)
end

---@public
function EffectorContainerClass:TickEffectorContainer(InDeltaTime, InTimestampSec)
    for i = 1, #self._Effectors do    
        local effector = self._Effectors[i]
        effector:TickEffector(InDeltaTime, InTimestampSec)
        if effector:IsEffectorExpried(InTimestampSec) then
            effector:InactiveEffector()
            self:RemoveEffector(effector)
        end
    end
end

---@public
---@param InEffector EffectorBaseClass
function EffectorContainerClass:AddEffector(InEffector)
    InEffector:ActiveEffector(self._EffectManager:GetTimestampSec())
    table.insert(self._Effectors, InEffector)
end

---@public
---@param InEffector EffectorBaseClass
function EffectorContainerClass:RemoveEffector(InEffector)
    for i = 1, #self._Effectors do
        local effector = self._Effectors[i]
        if effector == InEffector then
            table.remove(self._Effectors, i)
            break
        end
    end
end

return EffectorContainerClass