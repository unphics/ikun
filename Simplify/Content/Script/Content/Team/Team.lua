---
---@brief 战斗团队
---@author zys
---@data Mon Mar 17 2025 16:22:31 GMT+0800 (中国标准时间)
---@detail 存储团队成员团队领导者, 记录入战状态并做出回应, 入战后根据角色情况(所有战场职业,实时信息)分配战场位置
---        记录敌人成员情况, 根据敌人情况(当前战场职业,实时信息)分配集火目标和阻挡目标
---

local InfluenceMapClass = require('Content/Team/InfluenceMap')
local TeamEnemyClass = require('Content/Team/TeamEnemy')
local TeamMemberClass = require('Content/Team/TeamMember')

---@class TeamClass : MdBase
---@field Member TeamMemberClass * 团队成员
---@field TeamEnemy TeamEnemyClass *
---@field DecisionInterval number 决策间隔
---@field DecisionTimeCount number 决策间隔计时
---@field bFight boolean
---@field BattlePosition table[]
local TeamClass = class.class 'TeamClass': extends 'MdBase' {
--[[public]]
    ctor = function()end,
    Init = function()end,
    Tick = function()end,
    IsInfight = function()end,
    Member = nil,
    TeamEnemy = nil,
--[[private]]
    UpdateDecisionInterval = function()end,
    InitAllocBattlePosition = function()end,
    DecisionInterval = nil,
    DecisionTimeCount = nil,
    bFight = nil,
    BattlePosition = nil,
}
function TeamClass:ctor()
    self.Member = class.new 'TeamMemberClass' (self)
    self.DecisionInterval = 10 -- default
    self.DecisionTimeCount = self.DecisionInterval + 0.1
    self.bFight = false
    self.TeamEnemy = class.new 'TeamEnemyClass' (self)
end
function TeamClass:Init()
    self.Member:ElectLeader()
end
function TeamClass:Tick(DeltaTime)
    if self.bFight then
        self.DecisionTimeCount = self.DecisionTimeCount + DeltaTime
        if self.DecisionTimeCount > self.DecisionInterval then
            self.DecisionTimeCount = self.DecisionTimeCount - self.DecisionInterval
            self:MakeDynaDecision()
        end
    end
end
---@public 入战
---@todo 这个入战的调用需要更多条件, 比如先让Role或者Leader判断
function TeamClass:FallInFight(Enemy)
    self.bFight = true
    self:InitAllocBattlePosition()
    self.TeamEnemy:EncounterEnemy(Enemy)
end
---@private 更新决策间隔(每隔多长时间进行一次决策)
---@todo 此项后面根据策划设定
function TeamClass:UpdateDecisionInterval()
    self.DecisionInterval = 2
end
---@private 入战后初始化分配战场位置
function TeamClass:InitAllocBattlePosition()
    local BattlePosition = {
        Frontline = {}, -- 前排
        Backline = {}, -- 后排
    }
    local AllMem = {}
    for _, m in ipairs(self.Member) do
        table.insert(AllMem, m)
    end
    ---@todo 这里先简单分一下前排后排
    local BacklineCount = math.floor(#AllMem / 2 + 0.5)
    local i = 1
    while AllMem[i] do
        if not (i > BacklineCount) then
            local m = AllMem[i]
            table.insert(BattlePosition.Backline, m)
            table.remove(AllMem)
            BacklineCount = BacklineCount - 1
        else
            i = i + 1
        end
    end
    BattlePosition.Frontline = AllMem

    self.BattlePosition = BattlePosition
end
---@public 在战斗中
---@return boolean
function TeamClass:IsInfight()
    return self.bFight
end

--------------------------------------------------------------------------
---------------------------------- 开发中 ---------------------------------
--------------------------------------------------------------------------

---@private 战斗中动态调整战场位置
function TeamClass:DynaAjustBattlePosition()

end
---@private 战斗中动态调整成员位置
function TeamClass:DynaAjustMemberLoc()
    
end
---@private 战斗中的动态决策
function TeamClass:MakeDynaDecision()
    self:MakeInfluenceMap()
    ---@step 动态调配各个战场位置的人员
    ---@step 找出对方
    ---@step 动态调整各个战场位置人员的位置Location
    ---@step 更改集火目标
    self:DynaAjustBattlePosition()
    self:DynaAjustMemberLoc()
end
---@todo 影响力图, 还在测试
local a = true
function TeamClass:MakeInfluenceMap()
    if a then
        local InfluenceMap = class.new 'InfluenceMapClass' (self.Member:GetLeader().Avatar:K2_GetActorLocation(), 400, 10) ---@type InfluenceMap
        InfluenceMap:AddRoles(self.Member)
        a = false
    end
end

return TeamClass