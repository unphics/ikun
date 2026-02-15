
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

local Class3 = require("Core/Class/class3")
local AbilityClass = require("System/Ability/Ability/Ability")
local FileSystem = require("System/File/FileSystem")
local ConfigSystem = require("System/Config/ConfigSystem")
local SkillClass = require("System/Ability/Ability/Skill")
local str_util = require("Core/Util/str_util")
local log = require("Core/Log/log")

---@class AbilityManager
---@field protected _System AbilitySystem
---@field protected _SkillList SkillClass[]
---@field protected _AbilityConfigData table<string, AbilityConfig>
---@field protected _SkillConfigData table<string, SkillConfig>
local AbilityManager = Class3.Class("AbilityManager")

---@public
---@param InSystem AbilitySystem
function AbilityManager:Ctor(InSystem)
    self._System = InSystem
    self._SkillList = {}
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
    self._SkillConfigData = skillParser:ToRows():ExtractHeaders():ToGrid():ToMap()
        :CastPairCol({"Param1", "Param2", "Param3", "Param4", "Param5", "Param6", "Param7", "Param8", "Param9"})
        :GetResult()
    skillParser:ReleaseParser()
end

---@public
---@param InAbilityKey string
---@param InOwner table
---@return AbilityClass?
function AbilityManager:CreateAbility(InAbilityKey, InOwner)
    local config = self:LookupAbilityConfig(InAbilityKey)
    if not config then
        log.warn_fmt("AbilityManager:CreateAbility(): Invalid AbilityKey = [%s]", InAbilityKey)
        return nil
    end
    local abilityClass = self:_LoadAbilityClass(config.AbilityTemplate)
    local ability = abilityClass:New(self, config, InOwner)
    return ability
end

---@public
---@param InAbilityClassName string
---@return AbilityClass
function AbilityManager:_LoadAbilityClass(InAbilityClassName)
    if str_util.is_empty(InAbilityClassName) then 
        return AbilityClass
    else
        local pathHeader = "Module/Ability/Ability/"
        local abilityClass = require(pathHeader..InAbilityClassName) ---@type AbilityClass
        return abilityClass
    end
end

---@public
---@param InSkillKey string
---@param InAbility AbilityClass
---@return SkillClass
function AbilityManager:AcquireSkill(InSkillKey, InAbility)
    local config = self:LookupSkillConfig(InSkillKey)
    local tmplClass = self:_LoadSkillClass(config.SkillTemplate)
    local skill = tmplClass:New(self, config) ---@type SkillClass
    table.insert(self._SkillList, skill)
    return skill
end

---@public
---@todo pool
---@param InSkillClass SkillClass
function AbilityManager:ReleaseSkill(InSkillClass)
    table_util.remove(self._SkillList, InSkillClass)
end

---@public
---@param InSkillClassName string
---@return SkillClass
function AbilityManager:_LoadSkillClass(InSkillClassName) -- const
    if str_util.is_empty(InSkillClassName) then 
        return SkillClass
    else
        local pathHeader = "Module/Ability/Skill/"
        local skillClass = require(pathHeader..InSkillClassName) ---@type SkillClass
        return skillClass
    end
end

---@public
---@param DeltaTime number
function AbilityManager:TickAbilityManager(DeltaTime)
    for i = #self._SkillList, 1, -1 do
        local skill = self._SkillList[i]
        skill:TickSkill(DeltaTime)
    end

    ---@todo DeadList
end

---@public [Config]
---@param InAbilityKey string
---@return AbilityConfig
function AbilityManager:LookupAbilityConfig(InAbilityKey) -- const
    return self._AbilityConfigData[InAbilityKey]
end

---@public [Config]
---@param InSkillKey string
---@return SkillConfig
function AbilityManager:LookupSkillConfig(InSkillKey) -- const
    return self._SkillConfigData[InSkillKey]
end

return AbilityManager