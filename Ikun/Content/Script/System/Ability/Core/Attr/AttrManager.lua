
--[[
-- -----------------------------------------------------------------------------
--  Brief       : 能力系统-属性管理器
--  File        : AttrManager.lua
--  Author      : zhengyanshuai
--  Date        : Fri Jan 16 2026 23:09:10 GMT+0800 (中国标准时间)
--  Description : 管理属性配置, 提供属性集工厂
--  License     : MIT License
-- -----------------------------------------------------------------------------
--  Copyright (c) 2026 zhengyanshuai
-- -----------------------------------------------------------------------------
--]]

local Class3 = require('Core/Class/Class3')
local FileSystem = require("System/File/FileSystem")
local ConfigSystem = require("System/Config/ConfigSystem")
local ExpLib = require('System/Ability/Core/Attr/Exp')
local AttrSetClass = require('System/Ability/Core/Attr/AttrSet')
local AttrDef = require('System/Ability/Core/Attr/AttrDef')
local ModifierClass = require('System/Ability/Core/Attr/Modifier')
local log = require('Core/Log/log')

---@alias FormulaFunction fun(Attributes: table<number, number>):number

---@class AttrConfig
---@field AttrKey string
---@field AttrName string
---@field IsFake boolean
---@field AttrFormula string

---@class AttrManager
---@field protected _System AbilitySystem
---@field protected _AttrConfig table<string, AttrConfig>
---@field protected _AttrFormula table<number, FormulaFunction>
---@field protected _AttrDependencies table<number, number[]> (属性, 该属性依赖的属性[]) 依赖查找表, 我依赖谁
---@field protected _AttrDependents table<number, number[]> (属性, 依赖该属性的属性[]) 反向依赖查找表, 谁依赖我
local AttrManager = Class3.Class('AttrManager')

---@private
---@param InSystem AbilitySystem
function AttrManager:Ctor(InSystem)
    self._AttrConfig = {}
    self._AttrFormula = {}
    self._AttrDependencies = {}
    self._AttrDependents = {}
    
    self._System = InSystem
end

---@public [Init]
function AttrManager:InitAttrManager()
    self:_LoadAttrConfig()
    self:_BuildAttrDependencies()
    self:_BuildAttrDependents()
    self:_BuildAttrFormulas()
end

---@public
---@return AttrSetClass
function AttrManager:CreateAttrSet()
    local attributes = {}
    for key, _ in pairs(self._AttrConfig) do
        local id = AttrDef[key]
        if id then
            attributes[id] = 0
        end
    end
    local set = AttrSetClass:New(self, attributes) ---@type AttrSetClass
    return set
end

---@public [Pure] [Formula]
---@param InAttrKey number|string
---@return FormulaFunction
function AttrManager:GetAttrFormula(InAttrKey)
    return self._AttrFormula[AttrDef.ToId(InAttrKey)]
end

---@public [Pure] [Dependence]
---@param InAttrKey number|string
function AttrManager:GetAttrDependencies(InAttrKey)
    return self._AttrDependencies[AttrDef.ToId(InAttrKey)]
end

---@protected [Init]
function AttrManager:_LoadAttrConfig()
    -- 解析属性配置表原文
    local file = FileSystem.Get():CreateConfigContext()
    if not file then
        log.error('zys AttrManager:_LoadAttrConfig(): Failed to create config file context!')
        return
    end
    file:ChangeDirectory('Ability')
    file:ChangeDirectory('Attr')
    local attrFileContent = file:ReadStringFile('Attr.csv')
    if not attrFileContent then
        log.error('zys AttrManager:_LoadAttrConfig(): Failed to read Attr.csv!')
        return
    end
    local attrParser = ConfigSystem.Get():CreateCSVParser(attrFileContent)
    if not attrParser then
        log.error('zys AttrManager:_LoadAttrConfig(): Failed to create csv parser!')
        return
    end
    self._AttrConfig = attrParser:ToRows():ExtractHeaders():ToGrid():ToMap():GetResult()
    attrParser:ReleaseParser()
end

---@protected [Init]
function AttrManager:_BuildAttrDependencies()
    if not self._AttrConfig or not next(self._AttrConfig) then
        log.error('zys AttrManager:_BuildAttrDependencies(): Failed to read AttrConfig!')
        return
    end

    local attrDeps = {} ---@type table<string, string[]>
    ---@param config AttrConfig
    for key, config in pairs(self._AttrConfig) do
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
        AttrDef[sorted[i]] = #sorted - i + 1
    end
    AttrDef.BuildIdToKey()
    
    local attrNumDeps = {}
    for key, deps in pairs(attrDeps) do
        local tb = {}
        for _, dep in ipairs(deps) do
            table.insert(tb, AttrDef[dep])
        end
        attrNumDeps[AttrDef[key]] = tb
    end
    
    self._AttrDependencies = attrNumDeps
end

---@public [Init]
function AttrManager:_BuildAttrDependents()
    if not self._AttrDependencies or (not next(self._AttrDependencies)) then
        log.error('zys AttrManager:_BuildAttrDependents(): Failed to read AttrDependencies!')
        return
    end
    local attrDependents = {}
    for attr, deps in pairs(self._AttrDependencies) do
        for _, dep in ipairs(deps) do
            if not attrDependents[dep] then
                attrDependents[dep] = {}
            end
            table.insert(attrDependents[dep], attr)
        end
    end
    self._AttrDependents = attrDependents
end

---@protected [Init]
function AttrManager:_BuildAttrFormulas()
    if not self._AttrConfig or not (next(self._AttrConfig)) then
        log.error('zys AttrManager:_BuildAttrFormulas(): Failed to read AttrConfig!')
        return
    end
    local attrFormula = {}
    ---@param config AttrConfig
    for key, config in pairs(self._AttrConfig) do
        local func = ExpLib.Compile(config.AttrFormula)
        if func then
            attrFormula[AttrDef[key]] = func
        end
    end
    self._AttrFormula = attrFormula
end

return AttrManager