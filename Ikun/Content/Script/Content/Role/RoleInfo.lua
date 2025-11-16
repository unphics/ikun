
---
---@brief 角色的基础信息类
---@author zys
---@data Sat Jun 14 2025 18:43:45 GMT+0800 (中国标准时间)
---

---@class RoleInfoClass
---@field OwnerRole RoleBaseClass
---@field RoleInstId number 角色实例Id
---@field RoleCfgId number 配置表模板Id
---@field RoleDispName string 角色名字
---@field bDead boolean
local RoleInfoClass = class.class'RoleInfoClass' {
--[[public]]
    ctor = function()end,
    InitRoleInstId = function()end,
    RoleDoDeath = function()end,
    RoleCfgId = nil,
    RoleDispName = nil,
    RoleInstId = nil,
    bDead = nil,
--[[private]]
    OwnerRole = nil,
}

---@param Role RoleBaseClass
function RoleInfoClass:ctor(Role, CfgId)
    local config = RoleMgr:GetRoleConfig(CfgId) ---@type RoleConfig
    self.OwnerRole = Role
    self.RoleCfgId = CfgId
    self.RoleDispName = config.RoleName
    self.bDead = true
end
---@param InstId number
function RoleInfoClass:InitRoleInstId(InstId)
    if self.RoleInstId then
        return log.error(log.key.roleinit, '重复初始化InstId')
    end
    if not InstId then
        return log.error(log.key.roleinit, '无效的InstId')
    end
    self.RoleInstId = InstId
    self.bDead = false
end
function RoleInfoClass:RoleDoDeath()
    self.bDead = true
end