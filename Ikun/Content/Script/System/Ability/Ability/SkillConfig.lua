
--[[
-- -----------------------------------------------------------------------------
--  Brief       : 能力系统-技能-技能配置
--  File        : AbilityManager.lua
--  Author      : zhengyanshuai
--  Date        : Fri Jan 02 2026 22:31:32 GMT+0800 (中国标准时间)
--  Description : 技能配置
--  License     : MIT License
-- -----------------------------------------------------------------------------
--  Copyright (c) 2026 zhengyanshuai
-- -----------------------------------------------------------------------------
--]]

local Class3 = require("Core/Class/Class3")
local ConfigSystem = require("System/Config/ConfigSystem")
local FileSystem = require("System/File/FileSystem")
local log = require('Core/Log/log')

---@class SkillConfig
---@field SkillKey string
---@field SkillName string
---@field SkillTemplate string

---@class SkillConfigClass
---@field private __SkillConfig table<string, SkillConfig>
local SkillConfigClass = Class3.Class("SkillConfigClass")

local SKILL_CONFIG_PATH = "Ability/Ability/Skill.csv"
local config = nil

---@return SkillConfigClass
function SkillConfigClass.Get()
    if not config then
        config = SkillConfigClass:New()
        config:LoadSkillConfigs()
    end
    return config
end

function SkillConfigClass:Ctor()
end

---@public
function SkillConfigClass:LoadSkillConfigs()
    self:__LoadSkillConfig()
end

---@private
function SkillConfigClass:__LoadSkillConfig()
    local file = FileSystem.Get():MustReadSConfigFile(SKILL_CONFIG_PATH)
    log.assert_fmt(file, "SkillConfigClass:__LoadSkillConfig(): Failed to read [%s]", SKILL_CONFIG_PATH)

    local parser = ConfigSystem.Get():CreateCSVParser(file)
    local config = parser:ToRows():ExtractHeaders():ToGrid():ToMap()
        :CastPairCol({"Param1", "Param2", "Param3", "Param4", "Param5", "Param6", "Param7", "Param8", "Param9"})
        :GetResult()
    parser:ReleaseParser()
    self.__SkillConfig = config
end

---@public
---@return SkillConfig
function SkillConfigClass:LookupSkillConfig(InSkillKey) -- const
    return self.__SkillConfig[InSkillKey]
end

return SkillConfigClass