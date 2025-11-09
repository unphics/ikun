
---
---@brief 战斗行为
---@author zys
---@data Fri Apr 25 2025 22:27:17 GMT+0800 (中国标准时间)
---@deprecated
---

local BTType = require('Ikun.Module.AI.BT.BTType')
local FightPosDef = require 'Content/Role/FightPosDef'
local BBKeyDef = require('Ikun/Module/AI/BT/BBKeyDef')
local DftFPAsgnRate = require('Content/Team/Config/DftFPAsgnRate')

---@class TB_Fight : TeamBehaviorBase
---@field OwnerTeam TeamClass
---@field Army table
---@field DirectiveMoveCoord table<number, FVector> 指令性运动坐标(移动坐标, 分配三要素-1)
---@field DynaSuppressTarget table<number, RoleClass> 动态抑制目标(攻击目标, 分配三要素-2)
---@field TacticManeuverZone table<number, FVector> 战术机动区(活动范围, 分配三要素-1)
local TB_Fight = class.class 'TB_Fight' : extends 'TeamBehaviorBase' {
--[[public]]
    OnEncounterEnemy = function()end,
    Tick = function()end,
    ReadDirectiveMoveCoord = function()end,
    ReadDynaSuppressTarget = function()end,
--[[private]]
    AllMemberSwitchFightBT = function()end,
    CombatFeasibilityResolution = function()end,
    TacticalResolution = function()end,
    DefensivePos = function()end,
    AsgnFightPos = function()end,
    AsgnFightTarget = function()end,
    Army = nil,
    DirectiveMoveCoord = nil,
    DynaSuppressTarget = nil,
    TacticManeuverZone = nil,
}
function TB_Fight:ctor(OwnerTeam)
    class.TeamBehaviorBase.ctor(self, OwnerTeam)
    self.Army = {} -- 多个战场位置组成的军队
    self.DirectiveMoveCoord = {}
    self.DynaSuppressTarget = {}
    self.TacticManeuverZone = {}
end

---@private 动态调整
-- function TB_Fight:Tick(DeltaTime)
-- end

---@public [TryInit] 刚刚入战, 刚刚遭遇一队敌人时单次调用
---@param EnemyTeam TeamClass
function TB_Fight:OnEncounterEnemy(EnemyTeam)
    if not self.OwnerTeam.TeamEnemy:OnEncounterEnemy(EnemyTeam) then
        return
    end
    if self.OwnerTeam.bFight then
        return
    end
    -- 阶段一, 无情报
    self:AllMemberSwitchFightBT()
    self.Army = self:AsgnFightPos()
    self:DefensivePos(self.Army)
    self:AsgnFightTarget(self.Army)
    -- 阶段二, 有情报
    async_util.delay(self.OwnerTeam.TeamMember:GetLeader().Avatar, 2, function()
        self:AsgnFightTarget(self.Army)
    end)
end

---@private 和平入战时所有人切换到战斗树
function TB_Fight:AllMemberSwitchFightBT()
    local AllMember = self.OwnerTeam.TeamMember:GetAllMember()
    for _, ele in ipairs(AllMember) do
        ---@type RoleClass
        local Role = ele
        local NewBTKey = RoleMgr:GetRoleConfig(Role:GetRoleCfgId()).BTCfg[BTType.Fight]
        Role.BT.Blackboard:SetBBValue(BBKeyDef.BBNewBTKey, NewBTKey)        
    end
end

---@private [Pure] 作战可行性决议; 打或跑
function TB_Fight:CombatFeasibilityResolution(Army)
    return true
end

---@private [Static] 战术决议
function TB_Fight:TacticalResolution(Army)
    local backlineCount = #Army[FightPosDef.Backline]
    local frontlineCount = #Army[FightPosDef.Frontline]
    local rate = backlineCount / (backlineCount + frontlineCount)
    local threshold = 0.3 -- 后排数量阈值，超过这个值则前排保守

    if rate > threshold then
    else
    end
end

---@private [Pure] 分配战场位置
function TB_Fight:AsgnFightPos()
    local tbMaxFPCount = self.OwnerTeam.TeamMember:CalcMaxCountPerPos()
    local tbFPAsgnRate = {} -- 此时团队的职业比率
    local nSumFPRate = 0
    for def, rate in pairs(DftFPAsgnRate) do
        if tbMaxFPCount[def] then
            tbFPAsgnRate[def] = rate
            nSumFPRate = nSumFPRate + rate
        end
    end
    
    local Army = {} -- 众多战场位置组成的军队
    for enum_key, enum_val in pairs(FightPosDef) do
        Army[enum_val] = {}
    end

    -- 军队此战场位置需要人
    ---@param nStdFPRate number 此局此战场位置标准占比(此位置配给 : 总配给)
    local IsArmyNeedFP = function(Army, FPDef, nStdFPRate)
        local Total = 0
        for def, arrRole in pairs(Army) do
            Total = Total + #arrRole
        end
        return (#Army[FPDef] / Total) < nStdFPRate
    end
    
    local tbSingleFP, tbMultiFP = self.OwnerTeam.TeamMember:GetAllMember_PosCount()
    ---@todo 优先处理只能承担单一职业的角色; 此处略过
    for _, ele in ipairs(tbMultiFP) do
        local Role = ele ---@type RoleClass
        local tbFP = RoleMgr:GetRoleConfig(Role:GetRoleCfgId()).FightPosAssign
        local FightPos = nil
        ---@todo (if 有得跑 or 有牧师)血量极少, 强制后排
        ---@todo 血量较少, 优先后排
        ---@step 根据这场战斗的战场位置评估分配率决定
        for _, FP in ipairs(tbFP) do
            if IsArmyNeedFP(Army, FP, tbFPAsgnRate[FP] / nSumFPRate) then
                FightPos = FP
                goto do_asgn
            end
        end
        FightPos = tbFP[1]
        ::do_asgn::
        table.insert(Army[FightPos], Role)
    end
    return Army
end
---@private [Pure] 防御姿态
function TB_Fight:DefensivePos(Army)
    local OwnerLoc = self.OwnerTeam.TeamMove:CalcTeamMemberCenter(self.OwnerTeam.TeamMember:GetAllMember())
    local EnemyLoc = self.OwnerTeam.TeamMove:CalcTeamMemberCenter(self.OwnerTeam.TeamEnemy:GetAllEnemy())
    if UE.UKismetMathLibrary.Vector_Distance(OwnerLoc, EnemyLoc) < 1000 then
        log.dev('距离过近')
    end
    local Dir = (EnemyLoc - OwnerLoc)
    Dir:Normalize()
    local FrontlineTarget = OwnerLoc + (Dir * 500)
    for _, ele in ipairs(Army[FightPosDef.Frontline]) do
        local Role = ele ---@type RoleClass
        local bSuccess, ResultLoc = class.NavMoveData.RandomNavPointInRadius(Role.Avatar, FrontlineTarget, 150)
        self.DirectiveMoveCoord[Role:GetRoleId()] = ResultLoc
    end
end

---@private [Pure] 分配目标
function TB_Fight:AsgnFightTarget(Army)
    local Enemy = self.OwnerTeam.TeamEnemy
    Enemy:SortEnemyByDist()
    ---@rule 给前排分配对面的前排
    for i, ele in ipairs(Army[FightPosDef.Frontline]) do
        local Role = ele ---@type RoleClass
        local perception = Enemy.dpEnemyPerception:dget(i)
        if not perception then
            break
        end
        self.DynaSuppressTarget[Role:GetRoleId()] = perception.Role
    end
    Enemy.FireTarget = Enemy.dpEnemyPerception:dget(1).Role
    ---@rule 给后排分配对面的前排
    for i, ele in ipairs(Army[FightPosDef.Backline]) do
        local Role = ele ---@type RoleClass
        self.DynaSuppressTarget[Role:GetRoleId()] = Enemy.dpEnemyPerception:dget(1).Role
    end
end

---@public 给行为树任务使用
---@param Id number RoleInstId
function TB_Fight:ReadDirectiveMoveCoord(Id)
    local MoveLoc = self.DirectiveMoveCoord[Id]
    if MoveLoc then
        self.DirectiveMoveCoord[Id] = nil
        return MoveLoc
    end
end

---@public 给行为树任务使用
---@param Id number RoleInstId
function TB_Fight:ReadDynaSuppressTarget(Id)
    local Role = self.DynaSuppressTarget[Id]
    if not Role or Role:IsRoleDead() then
        log.dev('TB_Fight:ReadDynaSuppressTarget 发现已经死亡的角色', Role and Id or 'nil', Role and Role:RoleName() or 'nil')
        -- self.OwnerTeam.TeamEnemy:RemoveEnemyRole(Role)
        self.OwnerTeam.TeamEnemy:CheckEnemyDead()
        local allEnemy = self.OwnerTeam.TeamEnemy:GetAllEnemy()
        if #allEnemy == 0 then
            self.OwnerTeam:NextTeamState(class.new 'TB_Patrol' (self.OwnerTeam))
            return
        end
        self:AsgnFightTarget(self.Army)
        Role = self.DynaSuppressTarget[Id]
    end
    return Role
end

---@deprecated [Pure] 进攻性站位，计算前排突击敌方后排的位置
function TB_Fight:OffensivePos(Army)
    log.dev('TB_Fight:OffensivePos 进攻站位')
    local OwnerLoc = self.OwnerTeam.TeamMove:CalcTeamMemberCenter(self.OwnerTeam.TeamMember:GetAllMember())
    local EnemyLoc = self.OwnerTeam.TeamMove:CalcTeamMemberCenter(self.OwnerTeam.TeamEnemy:GetAllEnemy())
    local Dir = (OwnerLoc - EnemyLoc)
    Dir:Normalize()
    local BacklineTarget = EnemyLoc + Dir * 500 -- 敌方后排的大致位置
    for _, ele in ipairs(Army[FightPosDef.Frontline]) do
        local Role = ele ---@type RoleClass
        local bSuccess, ResultLoc = class.NavMoveData.RandomNavPointInRadius(Role.Avatar, BacklineTarget, 150)
        self.OwnerTeam.TeamMove:SetMemberMoveTarget(Role, ResultLoc, true)
    end
end

---@deprecated
function TB_Fight:MakeInfluenceMap()
    if a then
        return
    end
    a = true
    if a then
        log.dev('影响力图')
        local AllMember = self.OwnerTeam.TeamMember:GetAllMember()
    local InfluenceMap = class.new 'InfluenceMapClass' (self.OwnerTeam.TeamMove:CalcTeamMemberCenter(AllMember), 50, 100) ---@type InfluenceMap
        InfluenceMap:AddRoles(AllMember)
        a = false
    end
end