
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
---@return RoleClass
function RoleMgrClass:FindRole(RoleInstId)
    return self.AllRoles[RoleInstId]
end
---@public
---@param Role RoleClass
function RoleMgrClass:NewRole(RoleInstId, Role)
    if not RoleInstId or not Role then
        return log.error('RoleMgrClass:NewRole(): 数据错误', RoleInstId, Role)
    end
    if self.AllRoles[RoleInstId] then
        return log.error('RoleMgrClass:NewRole(): 重复的Role', RoleInstId)
    end
    self.AllRoles[RoleInstId] = Role
end