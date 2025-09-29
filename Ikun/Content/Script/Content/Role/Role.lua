
---
---@brief   角色的基类
---@author  zys
---@data    Mon Jan 27 2025 23:56:14 GMT+0800 (中国标准时间)
---@desc    对于摆放在场景中的Chr或者Spawn出的Chr, 分配给他们ConfigId, 在Chr里构造Role, 然后Role开始在游戏内容管理中注册, 成为世界的一员
---

local BTDef = require('Ikun/Module/AI/BT/BTDef')
local TeamClass = require('Content/Team/Team')
local FightTargetClass = require('Content/Role/FightTarget')
local RoleInfoClass = require('Content/Role/RoleInfo')
require('Content/Role/RoleHoldLocation')
require('Content/Item/Bag')
require('Content/Chat/NpcChat')

---@class RoleClass
---@field RoleInfo RoleInfoClass * 角色基础信息
---@field Avatar BP_ChrBase * 角色在游戏场景中的AvatarActor
---@field Team TeamClass * 战斗团队
---@field BT LBT * 行为树
---@field BelongKingdomLua Kingdom * 所属国家
---@field QuestComp QuestCompClass * 角色的任务
---@field Bag BagClass * 背包
---@field HoldLocation RoleHoldLocationClass * 角色持有的地点
---@field QuestGiver QuestGiverClass
---@field NpcChat NpcChatClass
---@field bNpc boolean
local RoleClass = class.class 'RoleClass' {
--[[public]]
    ctor = function()end,
    RoleTick = function()end,
    InitByAvatar = function()end,
    SwitchNewBT = function()end,
    IsFirend = function()end,
    IsEnemy = function()end,
    AddEnemyChecked = function()end,
    RoleBeginDeath = function()end,
    HasTarget = function()end,
    GetTarget = function()end,
    GetBelongKingdom = function()end,
    GetRoleCfgId = function()end,
    GetRoleInstId = function()end,
    GetRoleDispName = function()end,
    IsRoleDead = function()end,
    Team = nil,
    QuestGiver = nil,
    QuestComp = nil,
    Bag = nil,
    NpcChat = nil,
    HoldLocation = nil,
--[[private]]
    RoleInfo = nil,
    Avatar = nil,
    BelongKingdomLua = nil,
    BT = nil,
    bNpc = nil,
}

---@override
function RoleClass:ctor()
    self.bNpc = false
end

---@override
function RoleClass:RoleTick(DeltaTime)
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
    if self.GAgent then
        self.GAgent:TickAgent(DeltaTime)
    end
end

---@public Chr以身上的RoleId初始化, 并且将自己挂靠到所属国家里
function RoleClass:InitByAvatar(Avatar, ConfigId, bNpc)
    local config = RoleMgr:GetRoleConfig(ConfigId) ---@type RoleConfig
    if not config then
        return log.error(log.key.roleinit,'投胎失败!!!')
    end
    
    self.RoleInfo = class.new 'RoleInfoClass' (self, ConfigId)
    self.Avatar = Avatar
    self.bNpc = bNpc

    self.QuestComp = class.new 'QuestCompClass'(self)
    self.QuestGiver = class.new 'QuestGiverClass'(self)
    self.Bag = class.new 'BagClass'(self)
    self.NpcChat = class.new 'NpcChatClass'(self)
    self.HoldLocation = class.new 'RoleHoldLocationClass'(self, ConfigId)

    local DistrictMgr = Cosmos:GetStar().DistrictMgr ---@type DistrictMgr
    self.BelongKingdomLua = DistrictMgr:FindKingdomByCfgId(config.BelongKingdom) ---@type Kingdom
    self.BelongKingdomLua:AddKingdomMember(self)
    
    self.Avatar.SkillComp:InitRoleSkill()
    
    if config.RoleId == 210105 then
        local agent = class.new 'GAgent' (self) ---@as GAgent
        -- agent:AddGoal(class.new'GGoal'('起床', {Sleep = false}))
        -- agent:AddGoal(class.new'GGoal'('散步', {}))
        -- agent:AddGoal(class.new'GGoal'('吃饭', {}))

        -- agent:AddGoal(class.new'GGoal'('去市场', {}))
        -- agent:AddGoal(class.new'GGoal'('摆摊', {}))
        -- agent:AddGoal(class.new'GGoal'('吆喝', {}))

        -- agent:AddGoal(class.new'GGoal'('收摊', {}))
        -- agent:AddGoal(class.new'GGoal'('休息', {}))

        -- agent:AddGoal(class.new'GGoal'('散步', {}))
        -- agent:AddGoal(class.new'GGoal'('睡觉', {}))
        self.GAgent = agent
    else
        if config.BTCfg and config.BTCfg.Init then
            self:SwitchNewBT(config.BTCfg.Init)
        else
            log.error('RoleClass:InitByAvatar()', '没有初始BT', self:GetRoleDispName())
        end
    end
end

function RoleClass:SwitchNewBT(NewBTKey)
    log.info('RoleClass:SwitchNewBT()', self:GetRoleDispName(), NewBTKey)
    if self.Avatar.RoleComp.bCustomStartBT then
        return
    end
    local BTClass = BTDef[NewBTKey]
    if not BTClass then
        log.error('RoleClass:SwitchNewBT()', 'no NewBTKey', NewBTKey, self:GetRoleDispName())
        return
    end
    self.BT = BTClass(self.Avatar)
    if not self.BT then
        self.BT = BTClass(self.Avatar)
        log.error('RoleClass:SwitchNewBT()', 'Failed to init BT', NewBTKey, self:GetRoleDispName())
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
    local OwnerRoleCfg = RoleMgr:GetRoleConfig(self:GetRoleCfgId())
    local OtherRoleCfg = RoleMgr:GetRoleConfig(OtherRole:GetRoleCfgId())
    if not OtherRoleCfg then
        return false
    end
    log.info('RoleClass:AddEnemyChecked; self =', OwnerRoleCfg:GetRoleDispName(), '; enemy =', OtherRoleCfg:GetRoleDispName())
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