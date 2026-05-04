
--[[
-- -----------------------------------------------------------------------------
--  Brief       : 能力系统-能力-能力工厂类
--  File        : AbilityFactory.lua
--  Author      : zhengyanshuai
--  Date        : Fri Apr 24 2026 00:35:28 GMT+0800 (中国标准时间)
--  License     : MIT License
-- -----------------------------------------------------------------------------
--  Copyright (c) 2026 zhengyanshuai
-- -----------------------------------------------------------------------------
--]]

local Class3 = require("Core/Class/Class3")
local ConfigSystem = require("System/Config/ConfigSystem")
local FileSystem = require("System/File/FileSystem")
local log = require('Core/Log/log')
local AbilityConfigClass = require("System/Ability/Ability/AbilityConfig")
local AbilityBaseClass = require("System/Ability/Ability/AbilityBase")

---@class AbilityFactoryClass
---@field private __CachedClasses table<string, AbilityBaseClass>
local AbilityFactoryClass = Class3.Class("AbilityFactoryClass")

local ABILITY_SCRIPT_PATH = "Module/Ability/Ability/"
local factory = nil

---@return AbilityFactoryClass
function AbilityFactoryClass.Get()
    if not factory then
        factory = AbilityFactoryClass:New()
    end
    return factory
end

function AbilityFactoryClass:Ctor()
    self.__CachedClasses = {}
end

---@public
---@param InAbilityKey string
---@param InOwnerAbilityPart AbilityPartClass
---@return AbilityBaseClass?
function AbilityFactoryClass:CreateAbility(InAbilityKey, InOwnerAbilityPart)
    local config = AbilityConfigClass.Get():LookupAbilityConfig(InAbilityKey)
    if not config then
        return nil
    end
    local abilityClass = self:__GetOrLoadAbilityClass(config.AbilityTemplate)
    if not abilityClass then
        return nil
    end
    return abilityClass:New(config, InOwnerAbilityPart)
end

---@return AbilityBaseClass?
function AbilityFactoryClass:__GetOrLoadAbilityClass(InClassName)
    local fullPath = nil
    if InClassName then
        local abilityClass = self.__CachedClasses[InClassName]
        if abilityClass then
            return abilityClass
        end
        local fullPath = ABILITY_SCRIPT_PATH..InClassName
        local success, abilityClass = pcall(require, fullPath)
        if success and abilityClass then
            self.__CachedClasses[InClassName] = abilityClass
            return abilityClass
        else ---@todo zys 这里临时都用base
            self.__CachedClasses[InClassName] = AbilityBaseClass
            return abilityClass
        end
    end
    log.error_fmt("AbilityFactoryClass:__GetOrLoadAbilityClass(): Invalid AbilityBaseClass! path=[%s], name=[%s]", fullPath, InClassName)
end

return AbilityFactoryClass
