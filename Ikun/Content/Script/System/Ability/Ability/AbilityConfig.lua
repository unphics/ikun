
--[[
-- -----------------------------------------------------------------------------
--  Brief       : 能力系统-能力-能力配置
--  File        : AbilityConfig.lua
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

---@class AbilityConfigClass
---@field private __AbilityConfig table<string, AbilityConfig>
local AbilityConfigClass = Class3.Class("AbilityConfigClass")

local ABILITY_CONFIG_PATH = "Ability/Ability/Ability.csv"
local config = nil

---@return AbilityConfigClass
function AbilityConfigClass.Get()
    if not config then
        config = AbilityConfigClass:New()
        config:LoadAbilityConfigs()
    end
    return config
end

function AbilityConfigClass:Ctor()
end

---@public
function AbilityConfigClass:LoadAbilityConfigs()
    local file = FileSystem.Get():MustReadSConfigFile(ABILITY_CONFIG_PATH)
    log.assert_fmt(file, "AbilityConfigClass:__LoadAbilityConfigs(): Failed to read [%s]", ABILITY_CONFIG_PATH)
    local parser = ConfigSystem.Get():CreateCSVParser(file)
    local config = parser:ToRows():ExtractHeaders():ToGrid():ToMap()
        :CastMapCol({"AbilitySkills"})
        :CastArrCol({"AbilityTags"})
        :GetResult()
    parser:ReleaseParser()
    self.__AbilityConfig = config
end

---@public
---@param InAbilityKey string
---@return AbilityConfig?
function AbilityConfigClass:LookupAbilityConfig(InAbilityKey)
    return self.__AbilityConfig[InAbilityKey]
end

return AbilityConfigClass