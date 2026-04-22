
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
local AttrDef = require("System/Ability/Attr/AttrDef")

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
---@field protected _AttrFormula table<integer, AttrFormulaFunction>
---@field protected _AttrReceiveFormula table<integer, AttrReceiveFormulaFunction>
---@field protected _AttrDependencies table<integer, integer[]> (属性, 该属性依赖的属性[]) 依赖查找表, 我依赖谁
---@field protected _AttrDependents table<integer, integer[]> (属性, 依赖该属性的属性[]) 反向依赖查找表, 谁依赖我
local AttrConfigClass = Class3.Class("AttrConfigClass")

function AttrConfigClass:Ctor()
end

---@public
function AttrConfigClass:LoadAttrConfigs()
    self:__LoadAttrConfig()
    self:__LoadAttrSetConfig()
    self:__BuildAttrDependencies()
    self:__BuildAttrDependents()
    self:__BuildAttrFormulas()
    self:__BuildAttrReceiveFormulas()
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

---@private
function AttrConfigClass:__BuildAttrDependencies()
    if not self.__AttrConfig or not next(self.__AttrConfig) then
        return
    end
    local attrDeps = {} ---@type table<string, string[]>

    for key, _ in pairs(self.__AttrConfig) do
        if not attrDeps[key] then
            attrDeps[key] = {}
        end
    end

    ---@param config AttrConfig
    for key, config in pairs(self.__AttrConfig) do
        local deps = ExpLib.CollectDeps(config.AttrFormula)
        if deps then
            for _, src in ipairs(deps) do
                if not attrDeps[key] then
                    attrDeps[key] = {}
                end
                table.insert(attrDeps[key], src)
            end
        end
    end

    local sorted = ExpLib.TopoSortDFS(attrDeps) ---@type string[]
    for i = #sorted, 1, -1 do
        AttrDef.Attr[sorted[i]] = #sorted - i + 1
    end
    AttrDef.BuildIdToKey()
    
    local attrNumDeps = {}
    for key, deps in pairs(attrDeps) do
        local tb = {}
        for _, dep in ipairs(deps) do
            table.insert(tb, AttrDef.Attr[dep])
        end
        attrNumDeps[AttrDef.Attr[key]] = tb
    end
    
    self.__AttrDependencies = attrNumDeps
end

function AttrConfigClass:__BuildAttrDependents()
    if not self.__AttrDependencies or not next(self.__AttrDependencies) then
        return
    end
    local attrDependents = {}
    for attr, deps in pairs(self.__AttrDependencies) do
        for _, dep in ipairs(deps) do
            if not attrDependents[dep] then
                attrDependents[dep] = {}
            end
            table.insert(attrDependents[dep], attr)
        end
    end
    self.__AttrDependents = attrDependents
end

---@private
function AttrConfigClass:__BuildAttrFormulas()
    if not self.__AttrConfig or not next(self.__AttrConfig) then
        return
    end
    local attrFormula = {}
    ---@param config AttrConfig
    for key, config in pairs(self.__AttrConfig) do
        local func = ExpLib.CompileAttrFormula(config.AttrFormula)
        if func then
            attrFormula[AttrDef.Attr[key]] = func
        end
    end
    self.__AttrFormula = attrFormula
end

---@private
function AttrConfigClass:__BuildAttrReceiveFormulas()
    if not self.__AttrConfig or not next(self.__AttrConfig) then
        return
    end
    local receiveFormula = {}
    for key, config in pairs(self.__AttrConfig) do
        local func = ExpLib.CompileAttrReceiveFormula(config.AttrReceiveFormula)
        if func then
            receiveFormula[AttrDef.Attr[key]] = func
        end
    end
    self.__AttrReceiveFormula = receiveFormula
end

return AttrConfigClass