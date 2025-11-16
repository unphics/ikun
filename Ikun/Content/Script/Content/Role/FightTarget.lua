
---
---@brief 保存战斗目标及处理角色的战斗目标相关业务; 此功能将近废弃
---@author zys
---@data Tue Apr 15 2025 23:23:00 GMT+0800 (中国标准时间)
---

---@class FightTargetClass
---@field TargetRole RoleBaseClass
---@field OwnerRole RoleBaseClass
local FightTargetClass = class.class 'FightTargetClass' {
--[[public]]
    ctor = function()end,
--[[private]]
    TargetRole = nil,
    OwnerRole = nil,
}
---@public
---@param OwnerRole RoleBaseClass
function FightTargetClass:ctor(OwnerRole)
    self.OwnerRole = OwnerRole
end
---@public 设置战斗目标
function FightTargetClass:SetTarget(Role)
    self.TargetRole = Role
end
---@public 获取战斗目标
---@return RoleBaseClass
function FightTargetClass:GetTarget()
    return self.TargetRole
end
---@public 日常调用, 检查目标死亡
function FightTargetClass:CheckTargetDead()
    if self.TargetRole:IsRoleDead() then
        self.TargetRole = nil
        self:OnTargetDeath()
    end
end
---@private 目标死亡后调用, 可以干点别的
function FightTargetClass:OnTargetDeath()
end

return FightTargetClass