
--[[
-- -----------------------------------------------------------------------------
--  Brief       : 能力系统-效果-效果管理器
--  File        : EffectManager.lua
--  Author      : zhengyanshuai
--  Date        : Mon Mar 16 2026 16:31:18 GMT+0800 (中国标准时间)
--  Description : 效果管理器
--  License     : MIT License
-- -----------------------------------------------------------------------------
--  Copyright (c) 2026 zhengyanshuai
-- -----------------------------------------------------------------------------
--]]

local FileSystem = require("System/File/FileSystem")
local ConfigSystem = require("System/Config/ConfigSystem")
local log = require('Core/Log/log')
local StrUtils = require("Core/Utils/StrUtils")
local EffectorBaseClass = require("System/Ability/Effect/EffectorBase")
local TagUtils = require("System/Ability/Tag/TagUtils")
local Class3 = require('Core/Class/Class3')
local ExpLib = require("System/Ability/Exp/ExpLib")

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

---@class EffectManager
---@field protected _System AbilitySystem
---@field protected _EffectorConfigData EffectorConfig
---@field protected _EffectorContainers EffectorContainerClass[]
local EffectManager = Class3.Class('EffectManager')

---@public
function EffectManager:Ctor(InSystem)
    self._System = InSystem
    self._EffectorContainers = {}
end

---@public
function EffectManager:InitEffectManager()
    self:_LoadConfig()
end

---@public
function EffectManager:TickEffectManager(InDeltaTime)
    local timestampSec = self:GetTimestampSec()
    for i = 1, #self._EffectorContainers do
        local container = self._EffectorContainers[i]
        container:TickEffectorContainer(InDeltaTime, timestampSec)
    end
end

---@public
---@return EffectorConfig?
function EffectManager:LookupEffectorConfig(InEffectorKey) -- const
    return self._EffectorConfigData[InEffectorKey]
end

---@public
---@param InEffectorContainer EffectorContainerClass
function EffectManager:AddEffectorContainer(InEffectorContainer)
    table.insert(self._EffectorContainers, InEffectorContainer)
end

---@public
---@param InEffectorContainer EffectorContainerClass
function EffectManager:RemoveEffectorContainer(InEffectorContainer)
    for i = 1, #self._EffectorContainers do
        local container = self._EffectorContainers[i]
        if container == InEffectorContainer then
            table.remove(self._EffectorContainers, i)
            break
        end
    end
end

---@public
---@return EffectorBaseClass?
function EffectManager:CreateEffector(InEffectorKey)
    local config = self:LookupEffectorConfig(InEffectorKey)
    if not config then
        log.error_fmt("EffectManager:CreateEffector(): Invalid EffectorKey = [%s]", InEffectorKey)
        return
    end

    local effectorClass = self:_LoadEffectorClass(config.EffectTemplate)
    if not effectorClass then
        log.error_fmt("EffectManager:CreateEffector(): Invalid EffectorClass = [%s]", config.EffectTemplate)
        return
    end

    local effector = effectorClass:New(self, config)
    return effector
end

---@public
---@return number
function EffectManager:GetTimestampSec() -- const
    return self._System:GetTimestampSec()
end

---@public
---@return AbilitySystem
function EffectManager:GetAbilitySystem()
    return self._System
end

---@private
---@return EffectorBaseClass?
function EffectManager:_LoadEffectorClass(InEffectorClassName)
    local pathHeader = "Module/Ability/Effector/"
    local effectorClass = require(pathHeader..InEffectorClassName)
    return effectorClass
end

---@private
function EffectManager:_LoadConfig()
    local file = FileSystem.Get():CreateConfigContext()
    if not file then
        return
    end
    file:ChangeDirectory("Ability")
    file:ChangeDirectory("Effect")
    local content = file:ReadStringFile("Effector.csv")
    if not content then
        log.fatal_fmt("EffectManager:_LoadConfig(): Failed to load Effector.csv!!!")
        return
    end
    local effectorParser = ConfigSystem.Get():CreateCSVParser(content)

    if not effectorParser then
        log.fatal_fmt("EffectManager:_LoadConfig(): Failed to load Effector.csv!!!")
        return
    end

    self._EffectorConfigData = effectorParser:ToRows():ExtractHeaders():ToGrid():ToMap():CastMapCol({"AbilitySkills"}):CastArrCol({"GrantedTags", "BlockByTags", "CancelToTags"}):GetResult()
    effectorParser:ReleaseParser()

    ---@param config EffectorConfig
    for k, config in pairs(self._EffectorConfigData) do
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
end

return EffectManager