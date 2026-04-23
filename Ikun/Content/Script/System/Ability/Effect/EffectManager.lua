
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
    EffectConfigClass.Get()
end

---@public
function EffectManager:TickEffectManager(InDeltaTime)
end

---@public
---@return AbilitySystem
function EffectManager:GetAbilitySystem() -- const
    return self._System
end

return EffectManager