
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

---@public
---@todo 把创建流程拆出去
---@param InRoleConfigId integer
---@return RoleBaseClass?
function RoleMgrClass:AvatarBindRole(InRoleConfigId)
    local config = self:GetRoleConfig(InRoleConfigId)

    if not config then
        log.error('RoleMgrClass:AvatarBindRole()', '无效的RoleConfigId', InRoleConfigId)
        return
    end

    if config.bUniqueRole then
        if self._AllConfigRoles[InRoleConfigId] then
            return self._AllConfigRoles[InRoleConfigId][1]
        else
            local role = class.new 'RoleBaseClass'() ---@as RoleBaseClass
            role:InitRole(InRoleConfigId)
            return role
        end
    else
        local role = class.new 'RoleBaseClass'() ---@as RoleBaseClass
        role:InitRole(InRoleConfigId)
        return role
    end
end

---@public [Core] 新角色注册到管理器中
---@todo 统一初始化流程
---@param InRole RoleBaseClass
function RoleMgrClass:NewRole(InRole)
    local id = InRole:GetRoleId() ---@type integer
    local cfgId = InRole:GetRoleCfgId() ---@type integer

    if not InRole then
        return log.error('RoleMgrClass:NewRole(): 数据错误', id, InRole)
    end
    
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