
--[[
-- -----------------------------------------------------------------------------
--  Brief       : 能力系统-增益-增益管理器
--  File        : BuffManager.lua
--  Author      : zhengyanshuai
--  Date        : Tue Feb 10 2026 14:19:55 GMT+0800 (中国标准时间)
--  Description : 负责增益的生命周期管理, 统一调度, "规则执行", 归档与查询
--  License     : MIT License
-- -----------------------------------------------------------------------------
--  Copyright (c) 2026 zhengyanshuai
-- -----------------------------------------------------------------------------
--]]

local Class3 = require('Core/Class/Class3')
local TagUtil = require('System/Ability/Tag/TagUtil')
local FileSystem = require('System/File/FileSystem')
local ConfigSystem = require('System/Config/ConfigSystem')
local BuffContainer = require("System/Ability/Buff/BuffContainer")
local str_util = require("Core/Util/str_util")
local log = require("Core/Log/log")
local BuffBaseClass = require("System/Ability/Buff/BuffBase")

---@class BuffManager
---@field protected _System AbilitySystem
---@field protected _BuffConfigs table<string, BuffConfig> -- Key -> Config
---@field protected _BuffContainers BuffContainerClass[]
local BuffManager = Class3.Class('BuffManager')

---@public
---@param InSystem AbilitySystem
function BuffManager:Ctor(InSystem)
    self._System = InSystem
    self._BuffContainers = {}
end

---@public [Init]
function BuffManager:InitBuffManager()
    self:_LoadBuffConfig()
end

---@public [Config]
---@param InBuffKey string
---@return BuffConfig?
function BuffManager:LookupBuffConfig(InBuffKey)
    return self._BuffConfigs[InBuffKey]
end

---@private [Config]
function BuffManager:_LoadBuffConfig()
    local file = FileSystem.Get():CreateConfigContext()
    if not file then
        log.error('zys BuffManager:_LoadBuffConfig(): Failed to create FileContext!')
        return
    end
    file:ChangeDirectory('Ability')
    file:ChangeDirectory('Buff')
    local buffParser = ConfigSystem.Get():CreateCSVParser(file:ReadStringFile('Buff.csv'))
    if not buffParser then
        log.error('zys BuffManager:_LoadBuffConfig(): Failed to create CSVParser!')
        return
    end
    self._BuffConfigs = buffParser:ToRows():ExtractHeaders():ToGrid():ToMap():GetResult()
    buffParser:ReleaseParser()
end

---@public [Tick]
---@param InDeltaTime number
function BuffManager:TickBuffManager(InDeltaTime)
    local now = self:GetNowMs()
    self:_TickBuffManager(InDeltaTime, now)
end

---@public [BuffContainer]
---@param InOwnerPart AbilityPartClass
---@return BuffContainerClass
function BuffManager:AcquireBuffContainer(InOwnerPart)
    local container= BuffContainer:New(self, InOwnerPart)
    table.insert(self._BuffContainers, container)
    return container
end

---@public [BuffContainer]
---@param InBuffContainer BuffContainerClass
function BuffManager:ReleaseBuffContainer(InBuffContainer)
    for i = 1, #self._BuffContainers do
        local container = self._BuffContainers[i]
        if container == InBuffContainer then
            table.remove(self._BuffContainers, i)
            break
        end
    end
end

---@public [BuffContainer]
---@param InDeltaTime number
---@param InNowMs number
function BuffManager:_TickBuffManager(InDeltaTime, InNowMs)
    for i = 1, #self._BuffContainers do
        local container = self._BuffContainers[i]
        container:TickBuffContainer(InDeltaTime, InNowMs)
    end
end

---@public
---@param InBuffKey string
---@return BuffBaseClass?
function BuffManager:CreateBuff(InBuffKey)
    local config = self:LookupBuffConfig(InBuffKey)
    if not config then
        log.error_fmt("BuffManager:CreateBuff(): Invalid BuffKey = [%s]", InBuffKey)
        return
    end
    local buffClass = self:_LoadBuffClass(config.BuffTemplate)
    local buff = buffClass:New(config)
    return buff
end

---@protected
---@return BuffBaseClass
function BuffManager:_LoadBuffClass(InBuffClassName)
    if str_util.is_empty(InBuffClassName) then 
        return BuffBaseClass
    else
        local pathHeader = "Module/Ability/Buff/"
        local buffClass = require(pathHeader..InBuffClassName) ---@type BuffBaseClass
        return buffClass
    end
end

---@public [Pure]
---@return number
function BuffManager:GetNowMs()
    return self._System:GetNowMs()
end

return BuffManager
