
--[[
-- -----------------------------------------------------------------------------
--  Brief       : RoleMgrClass
--  File        : RoleMgr.lua
--  Author      : zhengyanshuai
--  Date        : Fri May 30 2025 23:46:56 GMT+0800 (中国标准时间)
--  Description : 角色系统-角色管理器
--  License     : MIT License
-- -----------------------------------------------------------------------------
--  Copyright (c) 2025-2026 zhengyanshuai
-- -----------------------------------------------------------------------------
--]]

require("System/Role/RoleBase")
local FileSystem = require("System/File/FileSystem")
local ConfigSystem = require("System/Config/ConfigSystem")
local table_util = require("Core/Util/table_util")
local TagUtil = require("System/Ability/Tag/TagUtil")
local log = require("Core/Log/log")

---@class RoleMgrClass
---@field _AllRoles table<integer, RoleBaseClass>
---@field _AllConfigRoles table<integer, RoleBaseClass[]>
---@field _RoleConfigData table<number, RoleConfig>
local RoleMgrClass = class.class 'RoleMgrClass'{
    ctor = function()end,
    GetOrCreateRole = function()end,
    RegisterRole = function()end,
    FindRole = function()end,
    GetRoleConfig = function()end,
    LateAtNight = function()end,
    _CreateRoleInst = function()end,
    _AllRoles = nil,
}

function RoleMgrClass:ctor()
    self._AllRoles = {}
    self._AllConfigRoles = {}
    self:_LoadConfig()
end

---@public 获取或创建一个角色实例
---@param InRoleConfigId integer
---@return RoleBaseClass?
function RoleMgrClass:GetOrCreateRole(InRoleConfigId)
    local config = self:GetRoleConfig(InRoleConfigId)

    if not config then
        log.error('RoleMgrClass:GetOrCreateRole()', '无效的RoleConfigId', InRoleConfigId)
        return nil
    end

    if config.bUniqueRole and self._AllConfigRoles[InRoleConfigId] then
        return self._AllConfigRoles[InRoleConfigId][1]
    end

    return self:_CreateRoleInst(InRoleConfigId, config)
end

---@private
---@param InRoleCfgId integer
---@param InConfig RoleConfig
---@return RoleBaseClass?
function RoleMgrClass:_CreateRoleInst(InRoleCfgId, InConfig)
    local role = class.new 'RoleBaseClass'() ---@as RoleBaseClass
    role:InitBaseInfo(InRoleCfgId, InConfig)

    local belongKingdom = role:GetBelongKingdom()
    local instId = belongKingdom:GenRoleInstId(role)
    role._RoleId = instId

    self:RegisterRole(role)

    role:InitComplexPart()

    belongKingdom:AddKingdomMember(role)

    return role
end

---@public 将新创建的角色注册到管理器中
---@param InRole RoleBaseClass
function RoleMgrClass:RegisterRole(InRole)
    local id = InRole:GetRoleId() ---@type integer
    local cfgId = InRole:GetRoleCfgId() ---@type integer
    
    if self._AllRoles[id] then
        return log.error('RoleMgrClass:NewRole(): 重复的Role', id)
    end

    self._AllRoles[id] = InRole

    if not self._AllConfigRoles[cfgId] then
        self._AllConfigRoles[cfgId] = {}
    end
    table.insert(self._AllConfigRoles[cfgId], InRole)
end

---@public [Inst] 半夜更新角色实例信息
function RoleMgrClass:LateAtNight()
    for id, role in pairs(self._AllRoles) do
        role:LateAtNight()
    end
end

---@public [Pure] 根据实例Id查找角色
---@param Id integer RoleInstId
---@return RoleBaseClass
function RoleMgrClass:FindRole(Id) -- const
    return self._AllRoles[Id]
end

---@public
---@param InRoleName string
---@return RoleBaseClass?
function RoleMgrClass:FindRoleByName(InRoleName)
    ---@param role RoleBaseClass
    for id, role in pairs(self._AllRoles) do
        if role:RoleName() == InRoleName then
            return role
        end
    end
end

---@public [Config] 根据配置Id获取配置表
---@return RoleConfig
function RoleMgrClass:GetRoleConfig(InRoleCfgId) -- const
    local config = self._RoleConfigData[tostring(InRoleCfgId)] ---@type RoleConfig
    return config
end

---@public [Config] 加载角色相关配置表
function RoleMgrClass:_LoadConfig() -- const
    local file = FileSystem.Get():CreateConfigContext()
    if not file then
        log.fatal("RoleMgrClass:_LoadConfig(): Failed to CreateConfigContext !")
        return
    end
    file:ChangeDirectory("Role")
    local roleParser = ConfigSystem.Get():CreateCSVParser(file:ReadStringFile("Role.csv"))
    self._RoleConfigData = roleParser:ToRows():ExtractHeaders():ToGrid():ToMap()
        :CastMapCol({"RoleSkills", "RoleAbility"})
        :CastArrCol({"HoldLocations", "RoleAttrSet"})
        :CastNumCol({"BelongKingdom", "RoleId"})
        :GetResult()
    roleParser:ReleaseParser()
end

return