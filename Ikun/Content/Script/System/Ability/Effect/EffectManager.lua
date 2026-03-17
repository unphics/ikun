
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

local FileSystem = require("System/File/FileSystem")
local ConfigSystem = require("System/Config/ConfigSystem")
local log = require('Core/Log/log')
local Class3 = require('Core/Class/Class3')

---@class EffectManager
---@field protected _System AbilitySystem
---@field protected _EffectorConfigData EffectConfig
local EffectManager = Class3.Class('EffectManager')

---@public
function EffectManager:Ctor(InSystem)
    self._System = InSystem
end

---@public
function EffectManager:InitEffectManager()
    self:_LoadConfig()
end

---@public
---@param InDeltaTime number
function EffectManager:TickEffectManager(InDeltaTime)
end

---@private
function EffectManager:_LoadConfig()
    local file = FileSystem.Get():CreateConfigContext()
    if not file then
        return
    end
    file:ChangeDirectory("Ability")
    file:ChangeDirectory("Effector")
    local effectorParser = ConfigSystem.Get():CreateCSVParser(file:ReadStringFile("Effector.csv"))

    if not effectorParser then
        log.fatal_fmt("EffectManager:_LoadConfig(): Failed to load Effector.csv!!!")
        return
    end

    self._EffectorConfigData = effectorParser:ToRows():ExtractHeaders():ToGrid():ToMap():CastMapCol({"AbilitySkills"}):GetResult()
    effectorParser:ReleaseParser()
end

---@public
---@return number
function EffectManager:GetTimestampSec() -- const
    return self._System:GetTimestampSec()
end

return EffectManager