
---
---@brief 角色的基础信息类, 包括基础的配置信息, 与角色生活状态(死活)无关(暂时)
---@author zys
---@data Sat Jun 14 2025 18:43:45 GMT+0800 (中国标准时间)
---

local RoleConfig = require('Content/Role/Config/RoleConfig')

---@class RoleInfoClass
---@field OwnerRole RoleClass
---@field RoleInstId number 角色实例Id
---@field RoleCfgId number 配置表模板Id
---@field RoleDispName string
local RoleInfoClass = class.class'RoleInfoClass' {
--[[public]]
    ctor = function()end,
    InitRoleInstId = function()end,
    RoleCfgId = nil,
    RoleDispName = nil,
    RoleInstId = nil,
--[[private]]
    OwnerRole = nil,
}

---@param Role RoleClass
function RoleInfoClass:ctor(Role, CfgId)
    local Config = RoleConfig[CfgId] ---@type RoleConfig
    self.OwnerRole = Role
    self.RoleCfgId = CfgId
    self.RoleDispName = Config.DisplayName
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
end