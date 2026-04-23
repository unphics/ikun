
--[[
-- -----------------------------------------------------------------------------
--  Brief       : 能力系统-能力-能力管理器
--  File        : AbilityManager.lua
--  Author      : zhengyanshuai
--  Date        : Fri Jan 02 2026 22:31:32 GMT+0800 (中国标准时间)
--  License     : MIT License
-- -----------------------------------------------------------------------------
--  Copyright (c) 2026 zhengyanshuai
-- -----------------------------------------------------------------------------
--]]

local Class3 = require("Core/Class/Class3")
local AbilityClass = require("System/Ability/Ability/Ability")
local FileSystem = require("System/File/FileSystem")
local ConfigSystem = require("System/Config/ConfigSystem")
local SkillBaseClass = require("System/Ability/Ability/SkillBase")
local StrUtils = require("Core/Utils/StrUtils")
local log = require("Core/Log/log")
local AbilityConfigClass = require("System/Ability/Ability/AbilityConfig")
local SkillConfigClass = require("System/Ability/Ability/SkillConfig")

---@class AbilityManager
---@field protected _System AbilitySystem
---@field protected _AbilityConfigData table<string, AbilityConfig>
local AbilityManager = Class3.Class("AbilityManager")

---@public
---@param InSystem AbilitySystem
function AbilityManager:Ctor(InSystem)
    self._System = InSystem
end

---@public
function AbilityManager:InitAbilityManager()
    AbilityConfigClass.Get()
    SkillConfigClass.Get()
end

---@public
function AbilityManager:TickAbilityManager(InDeltaTime)
end

return AbilityManager