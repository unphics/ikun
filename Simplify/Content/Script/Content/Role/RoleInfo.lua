
---
---@brief 角色的基础信息类
---@author zys
---@data Sat Jun 14 2025 18:43:45 GMT+0800 (中国标准时间)
---

---@class RoleInfoClass 角色的基础信息, 包括基础的配置信息
---@field OwnerRole RoleClass
---@field RoleCfgId number 配置表模板Id
local RoleInfoClass = class.class'RoleInfoClass' {
--[[public]]
    ctor = function()end,
    RoleCfgId = nil,
--[[private]]
    OwnerRole = nil,
}

---@param Role RoleClass
function RoleInfoClass:ctor(Role, CfgId)
    self.OwnerRole = Role
    self.RoleCfgId = CfgId
end