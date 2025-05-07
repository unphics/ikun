
---
---@brief 战斗行为
---@author zys
---@data Fri Apr 25 2025 22:27:17 GMT+0800 (中国标准时间)
---

local RoleConfig = require('Content/Role/Config/RoleConfig')
local BTType = require('Ikun.Module.AI.BT.BTType')
local FightPosDef = require 'Content/Role/FightPosDef'
local BBKeyDef = require('Ikun/Module/AI/BT/BBKeyDef')
local DftFPAsgnRate = require('Content/Team/Config/DftFPAsgnRate')

---@class TB_Fight : TeamBehaviorBase
---@field Army table
local TB_Fight = class.class 'TB_Fight' : extends 'TeamBehaviorBase' {
--[[public]]
    OnEncounterEnemy = function()end,
    Tick = function()end,
--[[private]]
    AllMemberBTSwitchFight = function()end,
    DefensivePos = function()end,
    AsgnFightPos = function()end,
    AsgnTarget = function()end,
    Army = nil,
}
---@public
---@param EnemyTeam TeamClass
function TB_Fight:OnEncounterEnemy(EnemyTeam)
    if not self.OwnerTeam.TeamEnemy:OnEncounterEnemy(EnemyTeam) then
        return
    end

    if not self.OwnerTeam.bFight then
        self.OwnerTeam.bFight = true
        self:AllMemberBTSwitchFight()
        self.Army = self:AsgnFightPos() -- 分化
        self:DefensivePos(self.Army) -- 防御性站位
    end
    -- 延迟一下
    async_util.delay(self.OwnerTeam.TeamMember:GetLeader().Avatar, 3, function()
        -- 分析敌方
        -- 打或跑(暂时默认打)
        
        -- 给出进一步站位(进攻性)
        -- 后排给出集火目标, 前排给出对线目标
        self:AsgnTarget(self.Army)
    end)
end

---@private 和平入战时所有人切换到战斗树
function TB_Fight:AllMemberBTSwitchFight()
    local AllMember = self.OwnerTeam.TeamMember:GetAllMember()
    for _, ele in ipairs(AllMember) do
        ---@type RoleClass
        local Role = ele
        local NewBTKey = RoleConfig[Role.RoleConfigId].BTCfg[BTType.Fight]
        Role.BT.Blackboard:SetBBValue(BBKeyDef.BBNewBTKey, NewBTKey)        
    end
end

---@private 分配战场位置
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
        local tbFP = RoleConfig[Role.RoleConfigId].FightPosAssign
        local FightPos = nil
        ---@todo (if 有得跑 or 有牧师)血量极少, 强制后排
        ---@todo 血量较少, 优先后排
        ---@step 根据这场战斗的战场位置评估分配率决定
        for _, FP in ipairs(tbFP) do
            if IsArmyNeedFP(Army, FP, tbFPAsgnRate[FP] / nSumFPRate) then
                FightPos = FP
                goto asgn 
            end
        end
        FightPos = tbFP[1]
        ::asgn::
        table.insert(Army[FightPos], Role)
    end
    return Army
end
function TB_Fight:DefensivePos(Army)
    log.dev('TB_Fight:DefensivePos 看看算的对不对')
    local OwnerLoc = self.OwnerTeam.TeamMove:CalcTeamMemberCenter(self.OwnerTeam.TeamMember:GetAllMember())
    local EnemyLoc = self.OwnerTeam.TeamMove:CalcTeamMemberCenter(self.OwnerTeam.TeamEnemy:GetAllEnemy())
    if UE.UKismetMathLibrary.Vector_Distance(OwnerLoc, EnemyLoc) < 1000 then
        log.dev('距离过近')
    end
    local Dir = (EnemyLoc - OwnerLoc)
    Dir:Normalize()
    local FrontlineTarget = OwnerLoc + Dir * 500
    for _, ele in ipairs(Army[FightPosDef.Frontline]) do
        local Role = ele ---@type RoleClass
        local bSuccess, ResultLoc = class.NavMoveData.RandomNavPointInRadius(Role.Avatar, FrontlineTarget, 150)
        self.OwnerTeam.TeamMove:SetMemberMoveTarget(Role, ResultLoc, true)
    end
end

function TB_Fight:AsgnTarget(Army)
    -- log.dev('TB_Fight:AsgnTarget() 找目标喽！！！')
    local Enemy = self.OwnerTeam.TeamEnemy
    Enemy:SortEnemyByDist()
    -- local avatar = Enemy.tbEnemyRolePerception[1].Role.Avatar
    -- UE.UKismetSystemLibrary.DrawDebugSphere(avatar, avatar:K2_GetActorLocation(), 100, 12, UE.FLinearColor(0, 0, 1), 1.5, 4)
    for i, ele in ipairs(Army[FightPosDef.Frontline]) do
        local Role = ele ---@type RoleClass
        if not Enemy.tbEnemyRolePerception[i] then
            break
        end
        Role.BT.Blackboard:SetBBValue(BBKeyDef.FightTarget, Enemy.tbEnemyRolePerception[i].Role)
    end
    Enemy.FireTarget = Enemy.tbEnemyRolePerception[1].Role

    for i, ele in ipairs(Army[FightPosDef.Backline]) do
        local Role = ele ---@type RoleClass
        if not Enemy.tbEnemyRolePerception[i] then
            break
        end
        Role.BT.Blackboard:SetBBValue(BBKeyDef.FightTarget, Enemy.tbEnemyRolePerception[1].Role)
    end
end
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