
--[[
-- -----------------------------------------------------------------------------
--  Brief       : 能力系统-效果-效果工厂
--  File        : EffectFactory.lua
--  Author      : zhengyanshuai
--  Date        : Thu Apr 23 2026 21:54:40 GMT+0800 (中国标准时间)
--  Description : 效果工厂
--  License     : MIT License
-- -----------------------------------------------------------------------------
--  Copyright (c) 2026 zhengyanshuai
-- -----------------------------------------------------------------------------
--]]

local Class3 = require('Core/Class/Class3')
local ConfigSystem = require("System/Config/ConfigSystem")
local FileSystem = require("System/File/FileSystem")
local log = require('Core/Log/log')
local ExpLib = require("System/Ability/Exp/ExpLib")
local TagUtils = require("System/Ability/Tag/TagUtils")
local EffectConfigClass = require("System/Ability/Effect/EffectConfig")

---@class EffectFactoryClass
---@field private __CachedClasses table<string, EffectorBaseClass>
local EffectFactoryClass = Class3.Class()

local EFFECTOR_SCRIPT_PATH = "Module/Ability/Effector/"

local factory = nil

function EffectFactoryClass.Get()
    if not factory then
        factory = EffectFactoryClass:New()
    end
    return factory
end

function EffectFactoryClass:Ctor()
    self.__CachedClasses = {}
end

---@public
---@return EffectorBaseClass?
function EffectFactoryClass:CreateEffector(InEffectorKey)
    local config = EffectConfigClass.Get():LookupEffectConfig(InEffectorKey)
    if not config then
        log.error_fmt("EffectFactoryClass:CreateEffector(): Invalid EffectorKey = [%s]", InEffectorKey)
        return
    end

    local effectorClass = self:__GetOrLoadEffector(config.EffectTemplate)
    if not effectorClass then
        log.error_fmt("EffectFactoryClass:CreateEffector(): Invalid EffectorClass = [%s]", config.EffectTemplate)
        return
    end

    local effector = effectorClass:New(config)
    return effector
end

---@public
---@return EffectorBaseClass?
function EffectFactoryClass:__GetOrLoadEffector(InEffectorClassName)
    local fullPath = nil
    if InEffectorClassName then
        local effectorClass = self.__CachedClasses[InEffectorClassName]
        if effectorClass then
            return effectorClass
        end
        local fullPath = EFFECTOR_SCRIPT_PATH..InEffectorClassName
        local success, effectorClass = pcall(require, fullPath)
        if success and effectorClass then
            self.__CachedClasses[InEffectorClassName] = effectorClass
            return effectorClass
        end
    end
    log.error_fmt("EffectFactoryClass:__GetOrLoadEffector(): Failed to load class! path=[%s]", fullPath)
end

return EffectFactoryClass