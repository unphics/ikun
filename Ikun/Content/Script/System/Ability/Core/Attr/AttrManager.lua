
--[[
-- -----------------------------------------------------------------------------
--  Brief       : 技能系统-属性管理器
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

---@alias FormulaFunction fun(Attributes: table<number, number>):number

---@class AttrConfig
---@field AttrKey string
---@field AttrName string
---@field IsFake boolean
---@field AttrFormula string

---@class AttrManager
---@field protected _System AbilitySystem
---@field protected AttrConfig AttrConfig
---@field protected AttrFormula table<number, FormulaFunction>
---@field protected _AttrDependencies table<number, number[]>
local AttrManager = Class3.Class('AttrManager')

---@private
---@param InSystem AbilitySystem
function AttrManager:Ctor(InSystem)
    self._System = InSystem
end

---@public
function AttrManager:InitAttrManager()
    self:_LoadAttrConfig()
    self:_BuildAttrDependencies()
    self:_BuildAttrFormulas()
end

---@public
---@return AttrSetClass
function AttrManager:CreateAttrSet()
    local set = AttrSetClass:New() ---@type AttrSetClass
    return set
end

---@public
---@param InAttrKey number
---@return FormulaFunction
function AttrManager:GetAttrFormula(InAttrKey)
    return self.AttrFormula[InAttrKey]
end

---@protected
function AttrManager:_LoadAttrConfig()
    -- 解析属性配置表原文
    local file = FileSystem.Get():CreateConfigContext()
    if not file then
        return
    end
    file:ChangeDirectory('Ability')
    file:ChangeDirectory('Attr')
    local attrFileContent = file:ReadStringFile('Attr.csv')
    if not attrFileContent then
        return
    end
    local attrParser = ConfigSystem.Get():CreateCSVParser(attrFileContent)
    if not attrParser then
        return
    end
    self.AttrConfig = attrParser:ToRows():ExtractHeaders():ToGrid():ToMap():GetResult()
    attrParser:ReleaseParser()
end

---@protected
function AttrManager:_BuildAttrDependencies()
    if not self.AttrConfig or not next(self.AttrConfig) then
        return
    end

    local attrDeps = {} ---@type table<string, string[]>
    ---@param config AttrConfig
    for key, config in pairs(self.AttrConfig) do
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

    local sorted = ExpLib.TopologicalSortDFS(attrDeps) ---@type string[]
    for i = #sorted, 1, -1 do
        AttrDef[sorted[i]] = #sorted - i + 1
    end
    
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

---@protected
function AttrManager:_BuildAttrFormulas()
    local attrFormula = {}
    ---@param config AttrConfig
    for key, config in pairs(self.AttrConfig) do
        local func = ExpLib.Compile(config.AttrFormula)
        if func then
            attrFormula[AttrDef[key]] = func
        end
    end
    self.AttrFormula = attrFormula
end

return AttrManager