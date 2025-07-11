
---
---@brief 角色的基类
---@author zys
---@data Mon Jan 27 2025 23:56:14 GMT+0800 (中国标准时间)
---@desc 对于摆放在场景中的Chr或者Spawn出的Chr, 分配给他们ConfigId, 在Chr里构造Role, 然后Role开始在游戏内容管理中注册, 成为世界的一员
---

local RoleConfig = require('Content/Role/Config/RoleConfig')
local BTDef = require('Ikun/Module/AI/BT/BTDef')
local TeamClass = require('Content/Team/Team')
local FightTargetClass = require('Content/Role/FightTarget')
local RoleInfoClass = require('Content/Role/RoleInfo')

---@class RoleClass: MdBase
---@field RoleInfo RoleInfoClass * 角色基础信息
---@field Avatar BP_ChrBase * 角色在游戏场景中的AvatarActor
---@field Team TeamClass * 战斗团队
---@field BT LBT * 行为树
---@field BelongKingdomLua Kingdom * 所属国家
---@field bNpc boolean
local RoleClass = class.class 'RoleClass' : extends 'MdBase' {
--[[public]]
    ctor = function()end,
    Tick = function()end,
    InitByAvatar = function()end,
    SwitchNewBT = function()end,
    IsFirend = function()end,
    IsEnemy = function()end,
    AddEnemyChecked = function()end,
    HasTarget = function()end,
    GetTarget = function()end,
    GetBelongKingdom = function()end,
    Team = nil,
    GetRoleCfgId = function()end,
    GetRoleInstId = function()end,
    GetRoleDispName = function()end,
    IsRoleDead = function()end,
--[[private]]
    StartBT = function()end,
    RoleInfo = nil,
    Avatar = nil,
    BelongKingdomLua = nil,
    BT = nil,
    bNpc = nil,
}

function RoleClass:ctor()
    self.bNpc = false
end

function RoleClass:Tick(DeltaTime)
    if self.BT then
        self.BT:Tick(DeltaTime)
        if self:GetRoleInstId() == debug_util.debugrole then
            if debug_util.debug_bt == 1 then
                self.Avatar.RoleComp:LogBT2UI(self.BT:PrintBT())
            else
                self.Avatar.RoleComp:LogBT2UI('')
            end
        end
    end
end

---@public Chr以身上的RoleId初始化, 并且将自己挂靠到所属国家里
function RoleClass:InitByAvatar(Avatar, CfgId, bNpc)
    local Config = RoleConfig[CfgId] ---@type RoleConfig
    if not Config then
        return log.error(log.key.roleinit,'投胎失败!!!')
    end
    self.RoleInfo = class.new 'RoleInfoClass' (self, CfgId)
    self.Avatar = Avatar
    self.bNpc = bNpc

    local DistrictMgr = MdMgr.Cosmos:GetStar().DistrictMgr ---@type DistrictMgr
    self.BelongKingdomLua = DistrictMgr:FindKingdomByCfgId(Config.BelongKingdomCfgId) ---@type Kingdom
    self.BelongKingdomLua:AddKingdomMember(self)

    self:StartBT()
end
function RoleClass:StartBT()
    local RoleCfg = RoleConfig[self:GetRoleCfgId()]
    if RoleCfg then
        self:SwitchNewBT(RoleCfg.InitBT)
    end
end

function RoleClass:SwitchNewBT(NewBTKey)
    log.log('RoleDisplayName = '..tostring(self:GetRoleDispName())..', switch new bt: '..tostring(NewBTKey))
    if self.Avatar.RoleComp.bCustomStartBT then
        return
    end
    local BTClass = BTDef[NewBTKey]
    if not BTClass then
        log.error('Failed to index BTClass, bt key = '..tostring(NewBTKey)..', RoleDisplayName = '..tostring(self:GetRoleDispName()))
        return
    end
    self.BT = BTClass(self.Avatar)
        if not self.BT then
        log.error('Failed to init bt, bt key = '..tostring(NewBTKey)..', RoleDisplayName = '..tostring(self:GetRoleDispName()))
        return
    end
end

---@public 判断是友方
---@param OtherRole RoleClass
function RoleClass:IsFirend(OtherRole)
    local Weight = 0
    if self.BelongKingdomLua then
        Weight = Weight + self.BelongKingdomLua:CalcRoleKingdomFriendShip(OtherRole)
    end
    return Weight > 0
end

---@public 判断是敌人
---@param OtherRole RoleClass
function RoleClass:IsEnemy(OtherRole)
    local Weight = 0
    if self.BelongKingdomLua then
        Weight = Weight + self.BelongKingdomLua:CalcRoleKingdomFriendShip(OtherRole)
    end
    return Weight < 0
end

---@deprecated 给Role添加敌人
---@param OtherRole RoleClass
---@return boolean
function RoleClass:AddEnemyChecked(OtherRole)
    if not OtherRole then
        return false
    end
    if OtherRole:IsRoleDead() then
        return false
    end
    if not self:IsEnemy(OtherRole) then
        return false
    end
    local OwnerRoleCfg = RoleConfig[self:GetRoleCfgId()]
    local OtherRoleCfg = RoleConfig[OtherRole:GetRoleCfgId()]
    if not OtherRoleCfg then
        return false
    end
    log.log('RoleClass:AddEnemyChecked; self =', OwnerRoleCfg:GetRoleDispName(), '; enemy =', OtherRoleCfg:GetRoleDispName())
    self.FightTarget:SetTarget(OtherRole)
    return true
end

---@public [Data] 角色开始死亡流程
function RoleClass:RoleBeginDeath()
    self.RoleInfo:RoleDoDeath()
    if self.Team then
        self.Team.TeamSupport:StopSupportReq(self)
        self.Team.TeamMember:RemoveMember(rolelib.roleid(self))
    end
    self.BT = nil
end

---@public [Pure] 获取所属国家
---@return Kingdom
function RoleClass:GetBelongKingdom()
    return self.BelongKingdomLua
end

---@public [LBTCondition] [Pure]
function RoleClass:No()
    return false
end

---@public [LBTCondition] [Pure]
function RoleClass:Yes()
    return true
end

---@public [LBTCondition] [Pure] 角色此时有团队指导的移动目标
function RoleClass:HasTeamMoveTarget()
    return self.Team.TeamMove.mapMemberMoveTarget and self.Team.TeamMove.mapMemberMoveTarget[self:GetRoleInstId()] or nil
end

---@public [Debug] [Pure] 打印这个角色的信息
function RoleClass:PrintRole()
    local str = ''
    local hp = obj_util.is_valid(self.Avatar) and self.Avatar.AttrSet:GetAttrValueByName("Health")
    str = str..'{ Id:'..self:GetRoleInstId()..', Dead:'..tostring(self:IsRoleDead())..', hp:'..tostring(hp)..' }'
    return str
end

---@public [Pure] 获取角色配置Id
function RoleClass:GetRoleCfgId()
    return self.RoleInfo.RoleCfgId
end

---@public [Pure] 获取角色实力Id
function RoleClass:GetRoleInstId()
    return self.RoleInfo.RoleInstId
end

---@public [Pure] 获取角色显示名称
function RoleClass:GetRoleDispName()
    return self.RoleInfo.RoleDispName
end

---@public [Pure] 角色是否死亡
function RoleClass:IsRoleDead()
    return self.RoleInfo.bDead
end

require('Content/Role/Impl/RoleDef')