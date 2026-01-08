
--[[
-- -----------------------------------------------------------------------------
--  Brief       : SkillManager
--  File        : SkillManager.lua
--  Author      : zhengyanshuai
--  Date        : Fri Jan 02 2026 22:31:32 GMT+0800 (中国标准时间)
--  Description : 技能系统-技能管理器
--  License     : MIT License
-- -----------------------------------------------------------------------------
--  Copyright (c) 2026 zhengyanshuai
-- -----------------------------------------------------------------------------
--]]

local Class3 = require('Core/Class/Class3')
local Arms = require('System/Skill/Core/Skill/Arms')
local FileSystem = require('System/File/FileSystem')
local ConfigSystem = require('System/Config/ConfigSystem')
local SkillClass = require('System/Skill/Core/Skill/Skill')

---@class SkillManager
---@field _System SkillSystem
---@field _UpdateSkillList SkillClass[]
---@field ArmsConfig table<string, ArmsConfig>
---@field SkillConfig table<string, SkillConfig>
local SkillManager = Class3.Class('SkillManager')

---@public
---@param InSystem SkillSystem
function SkillManager:Ctor(InSystem)
    self._System = InSystem
    self._UpdateSkillList = {}
end

---@public
function SkillManager:InitSkillManager()
    self:LoadConfig()
end

---@public [Config]
function SkillManager:LoadConfig()
    local file = FileSystem.Get():CreateConfigContext()
    if not file then
        return
    end
    file:ChangeDirectory('Skill')
    file:ChangeDirectory('Skill')
    local armsParser = ConfigSystem.Get():CreateCSVParser(file:ReadStringFile('Arms.csv'))
    self.ArmsConfig = armsParser:ToRows():ExtractHeaders():ToGrid():ToMap():CastMapCol({'ArmsSkills'}):GetResult()
    armsParser:ReleaseParser()

    local skillParser = ConfigSystem.Get():CreateCSVParser(file:ReadStringFile('Skill.csv'))
    self.SkillConfig = skillParser:ToRows():ExtractHeaders():ToGrid():ToMap():CastPairCol({'Param1', 'Param2', 'Param3', 'Param4', 'Param5', 'Param6', 'Param7', 'Param8', 'Param9', }):GetResult()
    skillParser:ReleaseParser()
end

---@public [Config]
---@param InArmsKey string
---@return ArmsConfig
function SkillManager:LookupArmsConfig(InArmsKey)
    return self.ArmsConfig[InArmsKey]
end

---@public [Config]
---@param InSkillKey string
---@return SkillConfig
function SkillManager:LookupSkillConfig(InSkillKey)
    return self.SkillConfig[InSkillKey]
end

---@public
---@param InSkillKey string
---@return SkillClass
function SkillManager:SpawnSkill(InSkillKey)
    local config = self:LookupSkillConfig(InSkillKey)
    local tmplClass = SkillClass
    local skill = tmplClass:New(self) ---@type SkillClass
    table.insert(self._UpdateSkillList, skill)
    return skill
end

---@public
---@todo pool
---@param InSkillClass SkillClass
function SkillManager:RecycleSkill(InSkillClass)
    table_util.remove(self._UpdateSkillList, InSkillClass)
end

---@public
---@param DeltaTime number
function SkillManager:UpdateSkillManager(DeltaTime)
    for i = #self._UpdateSkillList, 1, -1 do
        local skill = self._UpdateSkillList[i]
        skill:UpdateSkill(DeltaTime)
    end

    ---@todo DeadList
end

return SkillManager