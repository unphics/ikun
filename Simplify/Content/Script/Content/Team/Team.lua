---
---@brief 战斗团队
---@author zys
---@data Mon Mar 17 2025 16:22:31 GMT+0800 (中国标准时间)
---@detail 存储团队成员团队领导者, 记录入战状态并做出回应, 入战后根据角色情况(所有战场职业,实时信息)分配战场位置
---        记录敌人成员情况, 根据敌人情况(当前战场职业,实时信息)分配集火目标和阻挡目标
---

local InfluenceMapClass = require('Content/Team/InfluenceMap')
local TeamEnemyClass = require('Content/Team/TeamEnemy')

---@class TeamClass : MdBase
---@field Member RoleClass[] 团队成员
---@field TeamLeader RoleClass 团队领导者
---@field DecisionInterval number 决策间隔
---@field DecisionTimeCount number 决策间隔计时
---@field bFight boolean
---@field BattlePosition table[]
---@field TeamEnemy  TeamEnemyClass
local TeamClass = class.class 'TeamClass': extends 'MdBase' {
--[[public]]
    ctor = function()end,
    Init = function()end,
    Tick = function()end,
    AddMem = function()end,
    FinishMake = function()end,
    GetAllMember = function()end,
    GetLeader = function()end,
    PrintMem = function()end,
    IsInfight = function()end,
--[[private]]
    ElectLeader = function()end,
    UpdateDecisionInterval = function()end,
    InitAllocBattlePosition = function()end,
    Member = nil,
    TeamLeader = nil,
    DecisionInterval = nil,
    DecisionTimeCount = nil,
    bFight = nil,
    BattlePosition = nil,
    TeamEnemy = nil
}
function TeamClass:ctor()
    self.Member = {}
    self.DecisionInterval = 10 -- default
    self.DecisionTimeCount = self.DecisionInterval + 0.1
    self.bFight = false
    self.TeamEnemy = class.new 'TeamEnemyClass' (self)
end
function TeamClass:Init()
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
---@public 添加成员
---@param Role RoleClass
function TeamClass:AddMem(Role)
    table.insert(self.Member, Role)
end
---@public 团队构建完毕, 开始工作
function TeamClass:FinishMake()
    self:ElectLeader()
end
---@public 获取所有成员
function TeamClass:GetAllMember()
    return table_util.shallow_copy(self.Member)
end
---@public 获取领导者
---@return RoleClass
function TeamClass:GetLeader()
    return self.TeamLeader
end
---@public 打印出所有成员的信息
function TeamClass:PrintMem()
    local str = 'Team Leader ='.. self.TeamLeader.Avatar:PrintRoleInfo() ..' :\n'
    for _, Role in ipairs(self.Member) do
        str = str .. '\t\t\t' .. Role.Avatar:PrintRoleInfo() .. '\n'
    end
    return str
end
---@public 入战
---@todo 这个入战的调用需要更多条件, 比如先让Role或者Leader判断
function TeamClass:FallInFight(Enemy)
    self.bFight = true
    self:InitAllocBattlePosition()
    self.TeamEnemy:EncounterEnemy(Enemy)
end
---@private 选举领导者
---@desc 很多团队属性需要按照Leader的属性来做影响系数, 可能以后有多重职业, 现在只有一个Leader
---@todo 以后Team中可以有多种职业
function TeamClass:ElectLeader()
    local TeamLeader = self.Member[1]
    self.TeamLeader = TeamLeader
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
        local InfluenceMap = class.new 'InfluenceMapClass' (self.TeamLeader.Avatar:K2_GetActorLocation(), 400, 10) ---@type InfluenceMap
        InfluenceMap:AddRoles(self.Member)
        a = false
    end
end

return TeamClass