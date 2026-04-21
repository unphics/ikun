
--[[
-- -----------------------------------------------------------------------------
--  Brief       : 能力系统-属性-属性配置
--  File        : AttrConfig.lua
--  Author      : zhengyanshuai
--  Date        : Tue Apr 21 2026 13:55:45 GMT+0800 (中国标准时间)
--  Description : 属性配置
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

---@alias AttrFormulaFunction fun(Attributes: table<integer, number>):number
---@alias AttrImposeFormulaFunction fun(SourceAttribute: table<integer, number>, TargetAttribute: table<integer, number>):number
---@alias AttrReceiveFormulaFunction fun(SourceAttribute: table<integer, number>, TargetAttribute: table<integer, number>, ImposeValue: number):number

---@class AttrSetConfig
---@field SetKey string
---@field SetDesc string
---@field SetAttrs string[]

---@class AttrConfig
---@field AttrKey string
---@field AttrName string
---@field AttrFormula string
---@field AttrReceiveFormula string
---@field IsChangeInstant boolean
---@field IsModifierInfinite boolean
---@field ModifierApplyStrategy string
---@field ModifierAdditiveStrategy string

local ATTR_CONFIG_PATH = "Ability/Attr/Attr.csv"
local ATTRSET_CONFIG_PATH = "Ability/Attr/Set.csv"

---@class AttrConfigClass
---@field protected __AttrConfig table<string, AttrConfig>
---@field protected __AttrSetConfig table<string, AttrSetConfig>
local AttrConfigClass = Class3.Class("AttrConfigClass")

---@public
function AttrConfigClass:LoadAttrConfigs()
    self:__LoadAttrConfig()
    self:__LoadAttrSetConfig()
end

---@private
function AttrConfigClass:__LoadAttrConfig()
    local file = FileSystem.Get():MustReadSConfigFile(ATTR_CONFIG_PATH)
    log.assert_fmt(file, "AttrConfigClass:__LoadAttrConfig(): Failed to read [%s]", ATTR_CONFIG_PATH)

    local attrParser = ConfigSystem.Get():CreateCSVParser(file)
    local attrConfig = attrParser:ToRows():ExtractHeaders():ToGrid():ToMap():CastBoolCol({"IsChangeInstant", "IsModifierInfinite"}):GetResult()
    attrParser:ReleaseParser()
    self.__AttrConfig = attrConfig
end

---@private
function AttrConfigClass:__LoadAttrSetConfig()
    local file = FileSystem.Get():MustReadSConfigFile(ATTRSET_CONFIG_PATH)
    log.assert_fmt(file, "AttrConfigClass:__LoadAttrSetConfig(): Failed to read [%s]", ATTRSET_CONFIG_PATH)

    local setParser = ConfigSystem.Get():CreateCSVParser(file)
    local attrSetConfig = setParser:ToRows():ExtractHeaders():ToGrid():ToMap():CastArrCol({"SetAttrs"}):GetResult()
    setParser:ReleaseParser()
    self.__AttrSetConfig = attrSetConfig
end

return AttrConfigClass