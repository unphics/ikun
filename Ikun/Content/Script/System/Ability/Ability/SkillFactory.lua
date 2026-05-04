
--[[
-- -----------------------------------------------------------------------------
--  Brief       : 能力系统-技能-技能工厂类
--  File        : SkillFactory.lua
--  Author      : zhengyanshuai
--  Date        : Fri Jan 02 2026 22:31:32 GMT+0800 (中国标准时间)
--  Description : 技能工厂类
--  License     : MIT License
-- -----------------------------------------------------------------------------
--  Copyright (c) 2026 zhengyanshuai
-- -----------------------------------------------------------------------------
--]]

local Class3 = require("Core/Class/Class3")
local ConfigSystem = require("System/Config/ConfigSystem")
local FileSystem = require("System/File/FileSystem")
local log = require('Core/Log/log')
local SkillConfigClass = require("System/Ability/Ability/SkillConfig")
local StrUtils = require("Core/Utils/StrUtils")

---@class SkillFactoryClass
---@field private __CachedClasses table<string, SkillBaseClass>
local SkillFactoryClass = Class3.Class("SkillFactoryClass")

local SKILL_SCRIPT_PATH = "Module/Ability/Skill/"
local factor = nil

---@return SkillFactoryClass
function SkillFactoryClass.Get()
    if not factor then
        factor = SkillFactoryClass:New()
    end
    return factor
end

function SkillFactoryClass:Ctor()
    self.__CachedClasses = {}
end

---@public
---@param InSkillKey string
---@param InAbility AbilityBaseClass
---@return SkillBaseClass?
function SkillFactoryClass:AcquireSkill(InSkillKey, InAbility)
    local config = SkillConfigClass.Get():LookupSkillConfig(InSkillKey)
    if not config then
        return nil
    end
    local skillClass = self:__GetOrLoadSkillClass(config.SkillTemplate)
    if not skillClass then
        return nil
    end
    local skill = skillClass:New(config) ---@type SkillBaseClass
    return skill
end

---@public
---@todo pool
---@param InSkillClass SkillBaseClass
function SkillFactoryClass:ReleaseSkill(InSkillClass)
end

---@private
---@return SkillBaseClass?
function SkillFactoryClass:__GetOrLoadSkillClass(InSkillClassName)
    local fullPath = nil
    if InSkillClassName then
        local skillClass = self.__CachedClasses[InSkillClassName]
        if skillClass then
            return skillClass
        end
        local fullPath = SKILL_SCRIPT_PATH..InSkillClassName
        local success, skillClass = pcall(require, fullPath)
        if success and skillClass then
            self.__CachedClasses[InSkillClassName] = skillClass
            return skillClass
        end
    end
    log.error_fmt("SkillFactoryClass:__GetOrLoadSkillClass(): Invalid SkillClass = [%s]", fullPath)
end

return SkillFactoryClass