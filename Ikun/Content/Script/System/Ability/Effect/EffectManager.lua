
--[[
-- -----------------------------------------------------------------------------
--  Brief       : 能力系统-效果-效果管理器
--  File        : EffectManager.lua
--  Author      : zhengyanshuai
--  Date        : Mon Mar 16 2026 16:31:18 GMT+0800 (中国标准时间)
--  Description : 效果管理器
--  License     : MIT License
-- -----------------------------------------------------------------------------
--  Copyright (c) 2026 zhengyanshuai
-- -----------------------------------------------------------------------------
--]]

local log = require('Core/Log/log')
local EffectorBaseClass = require("System/Ability/Effect/EffectorBase")
local Class3 = require('Core/Class/Class3')
local EffectConfigClass = require("System.Ability/Effect/EffectConfig")

---@class EffectManager
---@field protected _System AbilitySystem
---@field protected _EffectorContainers EffectorContainerClass[]
local EffectManager = Class3.Class('EffectManager')

---@public
function EffectManager:Ctor(InSystem)
    self._System = InSystem
    self._EffectorContainers = {}
end

---@public
function EffectManager:InitEffectManager()
    EffectConfigClass.Get():LoadEffectConfigs()
end

---@public
function EffectManager:TickEffectManager(InDeltaTime)
    local timestampSec = self:GetTimestampSec()
    for i = 1, #self._EffectorContainers do
        local container = self._EffectorContainers[i]
        container:TickEffectorContainer(InDeltaTime, timestampSec)
    end
end

---@public
---@return EffectConfigClass
function EffectManager:GetEffectConfig() -- const
    return EffectConfigClass
end

---@public
---@param InEffectorContainer EffectorContainerClass
function EffectManager:AddEffectorContainer(InEffectorContainer)
    table.insert(self._EffectorContainers, InEffectorContainer)
end

---@public
---@param InEffectorContainer EffectorContainerClass
function EffectManager:RemoveEffectorContainer(InEffectorContainer)
    for i = 1, #self._EffectorContainers do
        local container = self._EffectorContainers[i]
        if container == InEffectorContainer then
            table.remove(self._EffectorContainers, i)
            break
        end
    end
end

---@public
---@return number
function EffectManager:GetTimestampSec() -- const
    return self._System:GetTimestampSec()
end

---@public
---@return AbilitySystem
function EffectManager:GetAbilitySystem() -- const
    return self._System
end

return EffectManager