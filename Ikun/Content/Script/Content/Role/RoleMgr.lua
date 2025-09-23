
---
---@brief   RoleMgr
---@author  zys
---@data    Fri May 30 2025 23:46:56 GMT+0800 (中国标准时间)
---

---@class RoleConfig
---@field RoleId number
---@field RoleName string
---@field RoleDesc string
---@field BelongKingdom number
---@field RoleSkills number[]
---@field InitBT string
---@field Color number
---@field SpecialClass string
---@field FightPosAssign FightPosDef[]
---@field BTCfg table<BTType, string>
---@field RoleChat number[]
---@field HoldLocations number[]

---@class RoleMgrClass
---@field _AllRoles table<number, RoleClass>
local RoleMgrClass = class.class 'RoleMgrClass'{
    ctor = function()end,
    FindRole = function()end,
    NewRole = function()end,
    GetRoleConfig = function()end,
    _AllRoles = nil,
}

function RoleMgrClass:ctor()
    self._AllRoles = {}
end

---@public 根据示例Id查找角色
---@param Id number RoleInstId
---@return RoleClass
function RoleMgrClass:FindRole(Id)
    return self._AllRoles[Id]
end

---@public 新角色注册到管理器中
---@param Id number RoleInstId
---@param Role RoleClass
function RoleMgrClass:NewRole(Id, Role)
    if not Id or not Role then
        return log.error('RoleMgrClass:NewRole(): 数据错误', Id, Role)
    end
    if self._AllRoles[Id] then
        return log.error('RoleMgrClass:NewRole(): 重复的Role', Id)
    end
    self._AllRoles[Id] = Role
end

---@public 根据配置Id获取配置表
---@return RoleConfig
function RoleMgrClass:GetRoleConfig(RoleCfgId)
    local config = ConfigMgr:GetConfig('Role')[RoleCfgId] ---@type RoleConfig
    return config
end

return