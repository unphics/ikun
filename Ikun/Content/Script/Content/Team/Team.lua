---
---@brief 战斗团队
---@author zys
---@data Mon Mar 17 2025 16:22:31 GMT+0800 (中国标准时间)
---@detail 存储团队成员团队领导者, 记录入战状态并做出回应, 入战后根据角色情况(所有战场职业,实时信息)分配战场位置
---        记录敌人成员情况, 根据敌人情况(当前战场职业,实时信息)分配集火目标和阻挡目标
---@deprecated
---

require('Content/Team/InfluenceMap')
require('Content/Team/TeamEnemy')
require('Content/Team/TeamMember')
require('Content.Team/TeamMove')
require('Content/Team/TeamFence')
require('Content/Team/TeamSupport')
require('Content/Team/TeamInfo')

require('Content/Team/TeamBehavior/TeamBehaviorBase')
require('Content/Team/TeamBehavior/TB_Patrol')
require('Content/Team/TeamBehavior/TB_Fight')

---@class TeamClass
---@field TeamInfo TeamInfoClass
---@field TeamMember TeamMemberClass * 团队成员
---@field TeamEnemy TeamEnemyClass * 团队敌人
---@field CurTB TeamBehaviorBase * 团队行为
---@field TeamMove TeamMoveClass * 团队移动
---@field TeamFence TeamFenceClass * 栅栏
---@field TeamSupport TeamSupportClass * 团队支援
---@field DecisionInterval number 决策间隔
---@field DecisionTimeCount number 决策间隔计时
---@field bFight boolean
local TeamClass = class.class 'TeamClass'{
--[[public]]
    ctor = function()end,
    TeamInit = function()end,
    TeamTick = function()end,
    Encounter = function()end,
    NextTeamState = function()end,
    IsInfight = function()end,
    TeamMember = nil,
    TeamEnemy = nil,
    CurTB = nil,
    TeamMove = nil,
--[[private]]
    UpdateDecisionInterval = function()end,
    DecisionInterval = nil,
    DecisionTimeCount = nil,
    bFight = nil,
}

function TeamClass:ctor()
    self.TeamMember = class.new 'TeamMemberClass' (self)
    self.DecisionInterval = 10 -- default
    self.DecisionTimeCount = self.DecisionInterval + 0.1
    self.bFight = false
    self.TeamInfo = class.new 'TeamInfoClass'(self)
    self.TeamEnemy = class.new 'TeamEnemyClass' (self)
    self.TeamMove = class.new 'TeamMoveClass'(self)
    self.TeamFence = class.new 'TeamFenceClass'(self)
    self.TeamSupport = class.new 'TeamSupportClass'(self)
end

---@public
function TeamClass:TeamInit()
    self.TeamMember:ElectLeader()
    self:NextTeamState(class.new 'TB_Patrol' (self))
end

---@public
function TeamClass:TeamTick(DeltaTime)
    self.DecisionTimeCount = self.DecisionTimeCount + DeltaTime
    if self.DecisionTimeCount > self.DecisionInterval then
        self.DecisionTimeCount = self.DecisionTimeCount - self.DecisionInterval
        if self.CurTB and self.CurTB.Tick then
            self.CurTB:Tick(DeltaTime)
        end
    end
end

---@public
---@param TO TeamBehaviorBase
function TeamClass:NextTeamState(TO)
    if self.CurTB then
        self.CurTB:UninitTB()
    end
    self.CurTB = TO
    self.CurTB:InitTB()
end

---@public [Fwd] 遭遇敌人
---@param Enemy TeamClass
function TeamClass:Encounter(Enemy)
    self.CurTB:OnEncounterEnemy(Enemy)
end

---@public [Pure] 在战斗中
---@return boolean
function TeamClass:IsInfight()
    return self.bFight
end

---@public [Pure]
function TeamClass:IsTeamLive()
    return self.TeamInfo.bTeamLive
end

return TeamClass