
---
---@brief RoleMgr
---@author zys
---@data Fri May 30 2025 23:46:56 GMT+0800 (中国标准时间)
---

---@class RoleMgrClass : MdBase
---@field AllRoles table<number, RoleClass>
local RoleMgrClass = class.class 'RoleMgrClass' : extends 'MdBase' {
--[[public]]
    ctor = function()end,
--[[private]]
    AllRoles = nil,
}
function RoleMgrClass:ctor()
    self.AllRoles = {}
end
---@public
---@param Id number RoleInstId
---@return RoleClass
function RoleMgrClass:FindRole(Id)
    return self.AllRoles[Id]
end
---@public
---@param Id number RoleInstId
---@param Role RoleClass
function RoleMgrClass:NewRole(Id, Role)
    if not Id or not Role then
        return log.error('RoleMgrClass:NewRole(): 数据错误', Id, Role)
    end
    if self.AllRoles[Id] then
        return log.error('RoleMgrClass:NewRole(): 重复的Role', Id)
    end
    self.AllRoles[Id] = Role
end