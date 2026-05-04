
--[[
-- -----------------------------------------------------------------------------
--  Brief       : 能力系统-增益-增益工厂
--  File        : BuffFactory.lua
--  Author      : zhengyanshuai
--  Date        : Mon May 04 2026 23:34:12 GMT+0800 (中国标准时间)
--  License     : MIT License
-- -----------------------------------------------------------------------------
--  Copyright (c) 2026 zhengyanshuai
-- -----------------------------------------------------------------------------
--]]

local Class3 = require("Core/Class/Class3")
local log = require("Core/Log/log")
local BuffConfigClass = require("System/Ability/Buff/BuffConfig")

---@class BuffFactoryClass
---@field private __CachedClasses table<string, BuffBaseClass>
local BuffFactoryClass = Class3.Class("BuffFactoryClass")

local BUFF_SCRIPT_PATH = "Module/Ability/Buff/"
local factory = nil

---@public
---@return BuffFactoryClass
function BuffFactoryClass.Get()
    if not factory then
        factory = BuffFactoryClass:New()
    end
    return factory
end

function BuffFactoryClass:Ctor()
    self.__CachedClasses = {}
end

---@public
---@return BuffBaseClass?
function BuffFactoryClass:AcquireSkill(InBuffKey)
    local config = BuffConfigClass.Get():LookupBuffConfig(InBuffKey)
    if not config then
        return nil
    end
    local buffClass = self:__GetOrCreateBuffClass(config.BuffTemplate)
    if not buffClass then
        return nil
    end
    local buff = buffClass:New(config) ---@type BuffBaseClass
    return buff
end

---@private
---@return BuffBaseClass?
function BuffFactoryClass:__GetOrCreateBuffClass(InBuffClassName)
    local fullPath = nil
    if InBuffClassName then
        local buffClass = self.__CachedClasses[InBuffClassName]
        if buffClass then
            return buffClass
        end
        local fullPath = BUFF_SCRIPT_PATH..InBuffClassName
        local success, buffClass = pcall(require, fullPath)
        if success and buffClass then
            self.__CachedClasses[InBuffClassName] = buffClass
            return buffClass
        end
    end
    log.error_fmt("BuffFactoryClass:__GetOrCreateBuffClass(): Invalid BuffClass = [%s]", fullPath)
end

return BuffFactoryClass