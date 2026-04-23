
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

---@class AttrConfigClass
---@field private __AttrConfig table<string, AttrConfig>
---@field private __AttrFormula table<integer, AttrFormulaFunction>
---@field private __AttrReceiveFormula table<integer, AttrReceiveFormulaFunction>
---@field private __AttrDependencies table<integer, integer[]> (属性, 该属性依赖的属性[]) 依赖查找表, 我依赖谁
---@field private __AttrDependents table<integer, integer[]> (属性, 依赖该属性的属性[]) 反向依赖查找表, 谁依赖我
local AttrConfigClass = Class3.Class("AttrConfigClass")

local ATTR_CONFIG_PATH = "Ability/Attr/Attr.csv"
local config = nil

---@return AttrConfigClass
function AttrConfigClass.Get()
    if not config then
        config = AttrConfigClass:New()
        config:LoadAttrConfigs()
    end
    return config
end

function AttrConfigClass:Ctor()
end

---@public
function AttrConfigClass:LoadAttrConfigs()
    self:__LoadAttrConfig()
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

---@public
---@param InAttrKey integer|string
---@return AttrFormulaFunction
function AttrConfigClass:LookupAttrFormula(InAttrKey) -- const
    return self.__AttrFormula[AttrDef.ToId(InAttrKey)]
end

---@public
---@param InAttrKey integer|string
---@return AttrReceiveFormulaFunction
function AttrConfigClass:LookupAttrReceiveFormula(InAttrKey) -- const
    return self.__AttrReceiveFormula[AttrDef.ToId(InAttrKey)]
end

---@public
---@param InAttrKey integer|string
function AttrConfigClass:GetAttrDependencies(InAttrKey) -- const
    return self.__AttrDependencies[AttrDef.ToId(InAttrKey)]
end

---@public
---@param InAttrKey integer|string
function AttrConfigClass:GetAttrDependents(InAttrKey) -- const
    return self.__AttrDependents[AttrDef.ToId(InAttrKey)]
end

---@public
---@param InAttrKey integer|string
---@return AttrConfig
function AttrConfigClass:GetAttrConfig(InAttrKey) -- const
    return self.__AttrConfig[AttrDef.ToKey(InAttrKey)]
end

return AttrConfigClass