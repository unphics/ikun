
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

---@class RoleClass: MdBase
---@field DisplayName string * 显示名称
---@field RoleInstId number * 角色实例Id
---@field RoleConfigId number * 角色配置Id
---@field Avatar BP_ChrBase * 角色在游戏场景中的AvatarActor
---@field Team TeamClass * 战斗团队
---@field BT LBT * 行为树
---@field BelongKingdomLua Kingdom * 所属国家
---@field FightTarget FightTargetClass * 战斗目标
---@field Dead boolean 已经死亡
---@field bNpc boolean
local RoleClass = class.class 'RoleClass' : extends 'MdBase' {
--[[public]]
    ctor = function()end,
    Tick = function()end,
    InitByAvatar = function()end,
    GetDisplayName = function()end,
    SwitchNewBT = function()end,
    IsFirend = function()end,
    IsEnemy = function()end,
    AddEnemyChecked = function()end,
    HasTarget = function()end,
    GetTarget = function()end,
    GetBelongKingdom = function()end,
    RoleInstId = nil,
    Team = nil,
    FightTarget = nil,
--[[private]]
    StartBT = function()end,
    DisplayName = nil,
    RoleConfigId = nil,
    Dead = false,
    Avatar = nil,
    BelongKingdomLua = nil,
    BT = nil,
    bNpc = nil,
}
function RoleClass:ctor()
    self.Dead = false
    self.bNpc = false
    self.FightTarget = class.new'FightTargetClass'(self)
end
function RoleClass:Tick(DeltaTime)
    if self.Team and self.Team.TeamMember:GetLeader() == self then
        self.Team:Tick(DeltaTime)
    end
    if self.BT then
        self.BT:Tick(DeltaTime)
        if debug_util.debug_bt then
            self.Avatar.RoleComp:LogBT2UI(self.BT:PrintBT())
        end
    end
end
---@public Chr以身上的RoleId初始化, 并且将自己挂靠到所属国家里
function RoleClass:InitByAvatar(Avatar, Id, bNpc)
    local Config = RoleConfig[Id] ---@type RoleConfig
    self.Avatar = Avatar
    self.RoleConfigId = Id
    self.DisplayName = Config.DisplayName
    self.bNpc = bNpc

    local DistrictMgr = MdMgr.Cosmos:GetStar().DistrictMgr ---@type DistrictMgr
    self.BelongKingdomLua = DistrictMgr:FindKingdomByCfgId(Config.BelongKingdomCfgId) ---@type Kingdom
    self.BelongKingdomLua:AddKingdomMember(self)

    self:StartBT()
end
function RoleClass:GetDisplayName()
    return self.DisplayName
end
function RoleClass:StartBT()
    local RoleCfg = RoleConfig[self.RoleConfigId]
    if RoleCfg then
        self:SwitchNewBT(RoleCfg.InitBT)
    end
end
function RoleClass:SwitchNewBT(NewBTKey)
    log.log('RoleDisplayName = '..tostring(self.DisplayName)..', switch new bt: '..tostring(NewBTKey))
    local BTClass = BTDef[NewBTKey]
    if not BTClass then
        log.error('Failed to index BTClass, bt key = '..tostring(NewBTKey)..', RoleDisplayName = '..tostring(self.DisplayName))
        return
    end
    self.BT = BTClass(self.Avatar)
        if not self.BT then
        log.error('Failed to init bt, bt key = '..tostring(NewBTKey)..', RoleDisplayName = '..tostring(self.DisplayName))
        return
    end
end
---@public 判断是友方
---@todo 预期中使用权重判断: 自己,队友,团队,家族,国家,种族
---@param OtherRole RoleClass
function RoleClass:IsFirend(OtherRole)
    local Weight = 0
    if self.BelongKingdomLua then
        Weight = Weight + self.BelongKingdomLua:CalcRoleKingdomFriendShip(OtherRole)
    end
    ---@todo 此处简单判断大于零, 预期后面会有友好阈值
    return Weight > 0
end
---@public 判断是敌人
---@todo 预期中使用权重判断: 自己,队友,团队,家族,国家,种族
---@param OtherRole RoleClass
function RoleClass:IsEnemy(OtherRole)
    local Weight = 0
    if self.BelongKingdomLua then
        Weight = Weight + self.BelongKingdomLua:CalcRoleKingdomFriendShip(OtherRole)
    end
    ---@todo 此处简单判断小于零, 预期后面会有敌对阈值
    return Weight < 0
end
---@public 给Role添加敌人
---@param OtherRole RoleClass
---@return boolean
function RoleClass:AddEnemyChecked(OtherRole)
    if not OtherRole then
        return false
    end
    if OtherRole.Dead then
        return false
    end
    if not self:IsEnemy(OtherRole) then
        return false
    end
    local OwnerRoleCfg = RoleConfig[self.RoleConfigId]
    local OtherRoleCfg = RoleConfig[OtherRole.RoleConfigId]
    if not OtherRoleCfg then
        return false
    end
    log.log('RoleClass:AddEnemyChecked; self =', OwnerRoleCfg.DisplayName, '; enemy =', OtherRoleCfg.DisplayName)
    self.FightTarget:SetTarget(OtherRole)
    return true
end
function RoleClass:HasTarget()
    return self.FightTarget:GetTarget() and true or false
end
function RoleClass:GetTarget()
    return self.FightTarget:GetTarget()
end

function RoleClass:RoleBeginDeath()
    self.Dead = true
    self.BT = nil
end

---@return Kingdom
function RoleClass:GetBelongKingdom()
    return self.BelongKingdomLua
end

require('Content/Role/Impl/RoleDef')