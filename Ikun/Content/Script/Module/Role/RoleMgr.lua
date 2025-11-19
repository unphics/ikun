
---
---@brief   角色管理器
---@author  zys
---@data    Fri May 30 2025 23:46:56 GMT+0800 (中国标准时间)
---

require('Module/Role/RoleBase')

---@class RoleConfig
---@field RoleId number
---@field RoleName string
---@field RoleDesc string
---@field bUniqueRole boolean
---@field BelongKingdom number
---@field RoleSkills number[]
---@field InitBT string
---@field GoapKey string
---@field SpecialClass string
---@field FightPosAssign FightPosDef[]
---@field BTCfg table<BTType, string>
---@field RoleChat number[]
---@field HoldLocations number[]

---@class RoleMgrClass
---@field _AllRoles table<integer, RoleBaseClass>
---@field _AllConfigRoles table<integer, RoleBaseClass[]>
local RoleMgrClass = class.class 'RoleMgrClass'{
    ctor = function()end,
    FindRole = function()end,
    NewRole = function()end,
    GetRoleConfig = function()end,
    _AllRoles = nil,
}

function RoleMgrClass:ctor()
    self._AllRoles = {}
    self._AllConfigRoles = {}
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
function RoleMgrClass:FindRole(Id)
    return self._AllRoles[Id]
end

---@public [Pure] 根据配置Id获取配置表
---@return RoleConfig
function RoleMgrClass:GetRoleConfig(InRoleCfgId)
    local config = ConfigMgr:GetConfig('Role')[InRoleCfgId] ---@type RoleConfig
    return config
end

return