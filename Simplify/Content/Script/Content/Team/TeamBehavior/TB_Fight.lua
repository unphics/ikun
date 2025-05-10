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
function TB_Fight:ctor(OwnerTeam)
    self.OwnerTeam = OwnerTeam
    self.Army = {} -- 多个战场位置组成的军队
end
---@public 刚刚入战, 刚刚遭遇一队敌人时单次调用
---@param EnemyTeam TeamClass
function TB_Fight:OnEncounterEnemy(EnemyTeam)
    if not self.OwnerTeam.TeamEnemy:OnEncounterEnemy(EnemyTeam) then
        return
    end
    if not self.OwnerTeam.bFight then
        self.OwnerTeam.bFight = true
        ---@step 1, 所有人切换到战斗树
        self:AllMemberBTSwitchFight()
        ---@step 2, 己方单位分配战斗位置
        self.Army = self:AsgnFightPos()
        
        local backlineCount = #self.Army[FightPosDef.Backline]
        local frontlineCount = #self.Army[FightPosDef.Frontline]
        local rate = backlineCount / (backlineCount + frontlineCount)
        local threshold = 0.3 -- 后排数量阈值，超过这个值则前排保护后排

        ---@step 3, 给出防御性站位或进攻性站位
        if rate > threshold then
            -- 保护后排
            self:DefensivePos(self.Army)
        else
            -- 突击敌方后排 (需要实现 OffensivePos)
            self:OffensivePos(self.Army)
            -- self:DefensivePos(self.Army) -- 暂时使用 DefensivePos 代替
        end
    end
    -- 延迟一下
    async_util.delay(self.OwnerTeam.TeamMember:GetLeader().Avatar, 3, function()
        ---@step 4, 分析敌方
        ---@step 5, 打或跑(暂时默认打),此项后面再写
        
        ---@step 6, 给出进一步站位(进攻性)
        ---@step 7, 后排给出集火目标, 前排给出对线目标
        self:AsgnTarget(self.Army)
    end)
end

---@private 动态调整
function TB_Fight:Tick(DeltaTime)
    ---@step 1, 分析敌方
    ---@step 2, 判断撤退, 此项后面再写
    -- local frontline = self.Army[FightPosDef.Frontline]
    -- if frontline then
    --     for _, role in ipairs(frontline) do
    --         ---@type RoleClass
    --         local Role = role
    --         local hpRate = Role.Avatar:GetCurrentHealth() / Role.Avatar:GetMaxHealth()
    --         local threshold = 0.3 -- 血量阈值
    --         if hpRate < threshold then
    --             log.dev(string.format('前排单位 %s 血量过低，准备后撤', Role.Avatar:GetName()))
    --             local safeLoc = self.OwnerTeam.TeamMove:CalcTeamMemberCenter(self.OwnerTeam.TeamMember:GetAllMember()) - (self.OwnerTeam.TeamEnemy:CalcTeamMemberCenter(self.OwnerTeam.TeamEnemy:GetAllEnemy()) - self.OwnerTeam.TeamMove:CalcTeamMemberCenter(self.OwnerTeam.TeamMember:GetAllMember())):GetSafeNormal() * 500
    --             self.OwnerTeam.TeamMove:SetMemberMoveTarget(Role, safeLoc, true)
    --             ---@todo (if 有得跑 or 有牧师)血量极少, 强制后排
    --         end
    --     end
    -- end
    ---@step 3, 调整站位
    ---@step 4, 调整集火目标, 优先最近的敌人
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
---@private [Pure]
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

---@private [Pure] 进攻性站位，计算前排突击敌方后排的位置
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

---@private [Pure]
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