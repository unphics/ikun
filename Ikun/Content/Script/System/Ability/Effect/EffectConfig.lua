
--[[
-- -----------------------------------------------------------------------------
--  Brief       : 能力系统-效果-效果配置
--  File        : EffectConfig.lua
--  Author      : zhengyanshuai
--  Date        : Sun Apr 19 2026 10:49:51 GMT+0800 (中国标准时间)
--  Description : 效果配置
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

---@class EffectorConfig
---@field EffectKey string
---@field EffectTemplate string 模板
---@field EffectPeroid integer 优先级
---@field EffectDuration number 持续时间
---@field EffectPriority number 周期
---@field AttrImposeFml? {Formula:AttrImposeFormulaFunction, AttrId:integer}
---@field GrantedTags? integer[]
---@field BlockByTags? integer[]
---@field CancelToTags? integer[]

local EFFECTOR_CONFIG_PATH = "Ability/Effect/Effector.csv"
local EFFECTOR_SCRIPT_PATH = "Module/Ability/Effector/"

---@class EffectConfigClass
---@field protected _EffectorConfigData EffectorConfig
local EffectConfigClass = Class3.Class("EffectConfigClass")

local config = nil

---@public
---@return EffectConfigClass
function EffectConfigClass.Get()
    if not config then
        config = EffectConfigClass:New()
    end
    return config
end

---@public
function EffectConfigClass:LoadEffectConfigs()
    local file = FileSystem.Get():MustReadSConfigFile(EFFECTOR_CONFIG_PATH)
    log.assert_fmt(file, "EffectConfigClass:LoadEffectConfigs(): Failed to read [%s]", EFFECTOR_CONFIG_PATH)

    local effectorParser = ConfigSystem.Get():CreateCSVParser(file)
    local configData = effectorParser:ToRows():ExtractHeaders():ToGrid():ToMap():CastMapCol({"AbilitySkills"})
        :CastArrCol({"GrantedTags", "BlockByTags", "CancelToTags"}):GetResult()
    effectorParser:ReleaseParser()

    ---@param config EffectorConfig
    for k, config in pairs(configData) do
        if config.BlockByTags then
            local tbTags = config.BlockByTags
            config.BlockByTags = {}
            for _, tag in ipairs(tbTags) do
                table.insert(config.BlockByTags, TagUtils.RequestTag(tag))
            end
        end
        if config.CancelToTags then
            config.CancelToTags = {}
            local tbTags = config.CancelToTags
            for _, tag in ipairs(tbTags) do
                table.insert(config.CancelToTags, TagUtils.RequestTag(tag))
            end
        end
        if config.GrantedTags then
            local tbTags = config.GrantedTags
            config.GrantedTags = {}
            for _, tag in ipairs(tbTags) do
                table.insert(config.GrantedTags, TagUtils.RequestTag(tag))
            end
        end

        if config.AttrImposeFml then
            local fml, attr = ExpLib.CompileAttrImposeFormula(config.AttrImposeFml)
            if fml and attr then
                config.AttrImposeFml = {Formula = fml, AttrId = attr}
            end
        end
    end

    self._EffectorConfigData = configData
end

---@public
---@return EffectorConfig?
function EffectConfigClass:LookupEffectConfig(InEffectKey) -- const
    return self._EffectorConfigData[InEffectKey]
end

---@public
---@return EffectorBaseClass?
function EffectConfigClass:CreateEffector(InEffectorKey)
    local config = self:LookupEffectConfig(InEffectorKey)
    if not config then
        log.error_fmt("EffectConfigClass:CreateEffector(): Invalid EffectorKey = [%s]", InEffectorKey)
        return
    end

    local effectorClass = require(EFFECTOR_SCRIPT_PATH..config.EffectTemplate)
    if not effectorClass then
        log.error_fmt("EffectConfigClass:CreateEffector(): Invalid EffectorClass = [%s]", config.EffectTemplate)
        return
    end

    local effector = effectorClass:New(config)
    return effector
end

---@public
---@return EffectorBaseClass?
function EffectConfigClass:LoadEffectorClass(InEffectorClassName)
    local effectorClass = require(EFFECTOR_SCRIPT_PATH..InEffectorClassName)
    return effectorClass
end

return EffectConfigClass