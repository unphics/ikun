---
---@brief 角色的基类
---@desc  对于摆放在场景中的Chr或者Spawn出的Chr, 分配给他们ConfigId, 在Chr里构造Role, 然后Role开始在游戏内容管理中注册, 成为世界的一员
---

local RoleConfig = require('Content/Role/Config/RoleConfig')
local BTDef = require('Ikun/Module/AI/BT/BTDef')

---@class Role: MdBase
---@field DisplayName string
---@field RoleInstId number
---@field RoleConfigId number
---@field RoleConfig RoleConfig
---@field Dead boolean
---@field Avatar BP_ChrBase
---@field BelongKingdom number
---@field bNpc boolean
---@field BT LBT
---@field BB BB
local Role = class.class 'Role' : extends 'MdBase' {
--[[public]]
    ctor = function()end,
    InitByAvatar = function(Avatar, Id)end,
    Tick = function()end,
--[[private]]
    DisplayName = nil,
    RoleInstId = nil,
    RoleConfigId = nil,
    RoleConfig = nil,
    Dead = false,
    Avatar = nil,
    BelongKingdom = nil,
    bNpc = nil,
    BT = nil,
    BB = nil,
}
function Role:ctor()
    self.Dead = false
    self.bNpc = false
    ---@class BB
    ---@field Target Role
    ---@field MoveTarget FVector | AActor
    local BB = {
        Target = nil,
        MoveTarget = nil,
    }
    self.BB = BB
end
---@public Chr以身上的RoleId初始化, 并且将自己挂靠到所属国家里
function Role:InitByAvatar(Avatar, Id, bNpc)
    local Config = RoleConfig[Id] ---@type RoleConfig
    self.Avatar = Avatar
    self.RoleConfigId = Id
    self.DisplayName = Config.DisplayName
    self.BelongKingdom = Config.BelongKingdom
    self.RoleConfig = Config
    self.bNpc = bNpc

    local DistrictMgr = MdMgr.tbMd.ConMgr.tbCon.AreaMgr:GetStar().DistrictMgr ---@type DistrictMgr
    local Kingdom = DistrictMgr:GetKingdom(self.BelongKingdom) ---@type Kingdom
    Kingdom:AddKingdomMember(self)

    self:StartBT()
end
function Role:Tick(DeltaTime)
    if self.BT then
        self.BT:Tick(DeltaTime)
        self.Avatar.NpcComp:LogBT2UI(self.BT:PrintBT())
    end
end
function Role:GetDisplayName()
    return self.DisplayName
end
function Role:StartBT()
    if self.RoleConfigId ~= 4 then
        return
    end
    self.BT = BTDef[self.RoleConfig.InitBT](self.Avatar)
    if not self.BT then
        log.error('Role:StartBT: Failed to Init BT, DisplayName = ', self.DisplayName)
    end
end
---@param OtherRole Role
function Role:IsFirendlyForce(OtherRole)
    if OtherRole.BelongKingdom ~= self.BelongKingdom then
        return false
    end
    return true
end
---@param OtherRole Role
function Role:IsEnemy(OtherRole)
    if OtherRole.BelongKingdom ~= self.BelongKingdom then
        return true
    end
    return false
end
---@param OtherRole
---@return boolean
function Role:AddEnemyChecked(OtherRole)
    if self:IsEnemy(OtherRole) then
        log.dev('Role:AddEnemyChecked; self =', self.RoleConfig.DisplayName, '; enemy =', OtherRole.RoleConfig.DisplayName)
        self.BB.Target = OtherRole
    end
end
function Role:HasTarget()
    return self.BB.Target and true or false
end
function Role:GetTarget()
    return self.BB.Target
end