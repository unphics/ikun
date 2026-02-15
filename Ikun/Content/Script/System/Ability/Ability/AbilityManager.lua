
--[[
-- -----------------------------------------------------------------------------
--  Brief       : AbilityManager
--  File        : AbilityManager.lua
--  Author      : zhengyanshuai
--  Date        : Fri Jan 02 2026 22:31:32 GMT+0800 (中国标准时间)
--  Description : 能力系统-技能管理器
--  License     : MIT License
-- -----------------------------------------------------------------------------
--  Copyright (c) 2026 zhengyanshuai
-- -----------------------------------------------------------------------------
--]]

local Class3 = require("Core/Class/Class3")
local Ability = require("System/Ability/Ability/Ability")
local FileSystem = require("System/File/FileSystem")
local ConfigSystem = require("System/Config/ConfigSystem")
local SkillClass = require("System/Ability/Ability/Skill")

---@class AbilityManager
---@field protected _System AbilitySystem
---@field protected _UpdateSkillList SkillClass[]
---@field protected _AbilityConfigData table<string, AbilityConfig>
---@field protected _SkillConfigData table<string, SkillConfig>
local AbilityManager = Class3.Class("AbilityManager")

---@public
---@param InSystem AbilitySystem
function AbilityManager:Ctor(InSystem)
    self._System = InSystem
    self._UpdateSkillList = {}
end

---@public
function AbilityManager:InitAbilityManager()
    self:_LoadConfig()
end

---@protected [Config]
function AbilityManager:_LoadConfig()
    local file = FileSystem.Get():CreateConfigContext()
    if not file then
        return
    end
    file:ChangeDirectory("Ability")
    file:ChangeDirectory("Ability")
    local abilityParser = ConfigSystem.Get():CreateCSVParser(file:ReadStringFile("Ability.csv"))
    self._AbilityConfigData = abilityParser:ToRows():ExtractHeaders():ToGrid():ToMap():CastMapCol({"AbilitySkills"}):GetResult()
    abilityParser:ReleaseParser()

    local skillParser = ConfigSystem.Get():CreateCSVParser(file:ReadStringFile("Skill.csv"))
    self._SkillConfigData = skillParser:ToRows():ExtractHeaders():ToGrid():ToMap():CastPairCol({"Param1", "Param2", "Param3", "Param4", "Param5", "Param6", "Param7", "Param8", "Param9", }):GetResult()
    skillParser:ReleaseParser()
end

---@public
---@param InSkillKey string
---@return SkillClass
function AbilityManager:AcquireSkill(InSkillKey)
    local config = self:LookupSkillConfig(InSkillKey)
    local tmplClass = SkillClass
    local skill = tmplClass:New(self) ---@type SkillClass
    table.insert(self._UpdateSkillList, skill)
    return skill
end

---@public
---@todo pool
---@param InSkillClass SkillClass
function AbilityManager:ReleaseSkill(InSkillClass)
    table_util.remove(self._UpdateSkillList, InSkillClass)
end

---@public
---@param DeltaTime number
function AbilityManager:TickAbilityManager(DeltaTime)
    for i = #self._UpdateSkillList, 1, -1 do
        local skill = self._UpdateSkillList[i]
        skill:TickSkill(DeltaTime)
    end

    ---@todo DeadList
end

---@public [Config]
---@param InAbilityKey string
---@return AbilityConfig
function AbilityManager:LookupAbilityConfig(InAbilityKey)
    return self._AbilityConfigData[InAbilityKey]
end

---@public [Config]
---@param InSkillKey string
---@return SkillConfig
function AbilityManager:LookupSkillConfig(InSkillKey)
    return self._SkillConfigData[InSkillKey]
end

return AbilityManager