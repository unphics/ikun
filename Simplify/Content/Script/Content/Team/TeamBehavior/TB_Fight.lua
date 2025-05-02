
---
---@brief 战斗行为
---@author zys
---@data Fri Apr 25 2025 22:27:17 GMT+0800 (中国标准时间)
---

local RoleConfig = require('Content/Role/Config/RoleConfig')
local BTType = require('Ikun.Module.AI.BT.BTType')
local FightPosDef = require 'Content/Role/FightPosDef'

---@class TB_Fight : TeamBehaviorBase
---
local TB_Fight = class.class 'TB_Fight' : extends 'TeamBehaviorBase' {
--[[public]]
    OnEncounterEnemy = function()end,
--[[private]]
    AsgnFightPos = function()end,
}
---@public
---@param EnemyTeam TeamClass
function TB_Fight:OnEncounterEnemy(EnemyTeam)
    local AllMember = self.OwnerTeam.TeamMember:GetAllMember()
    for _, ele in ipairs(AllMember) do
        ---@type RoleClass
        local Role = ele
        local NewBTKey = RoleConfig[Role.RoleConfigId].BTCfg[BTType.Fight]
        Role.BT.Blackboard:SetBBValue('BBNewBTKey', NewBTKey)        
    end

    self.OwnerTeam.TeamEnemy:OnEncounterEnemy(EnemyTeam)

    ---@step 站位分化
    local Army = self:AsgnFightPos()
    ---@step 初步给出站位(根据方向, 防御性站位)
    self:DefensivePos(Army)
    
    ---@step 延迟一下
    ---@step 分析敌方角色
    ---@step 打或跑(暂时默认打)
    
    ---@step 给出进一步站位(进攻性)
    ---@step 后排给出集火目标, 前排给出对线目标
    async_util.delay(self.OwnerTeam.TeamMember:GetLeader().Avatar, 3, function()
        self:AsgnTarget(Army)
    end)
end

local DftFPAsgnRate = {} -- 默认的最佳战场位置配比(default fight position assign rate)
DftFPAsgnRate[FightPosDef.Frontline] = 1
DftFPAsgnRate[FightPosDef.Backline] = 2

---@private 分配战场位置
function TB_Fight:AsgnFightPos()
    ---@todo 暂时只有Lich一只怪, 暂定固定一些写法

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
    local OwnerLoc = self.OwnerTeam.TeamMember:GetLeader().Avatar:K2_GetActorLocation()
    local EnemyLoc = self.OwnerTeam.TeamEnemy.tbEnemyRolePerception[1].Role.Avatar:K2_GetActorLocation()
    if UE.UKismetMathLibrary.Vector_Distance(OwnerLoc, EnemyLoc) < 1000 then
        log.dev('距离过近')
    end
    local Dir = (EnemyLoc - OwnerLoc)
    Dir:Normalize()
    local FrontlineTarget = OwnerLoc + Dir * 500
    for _, ele in ipairs(Army[FightPosDef.Frontline]) do
        local Role = ele ---@type RoleClass
        local bSuccess, ResultLoc = class.NavMoveData.RandomNavPointInRadius(Role.Avatar, FrontlineTarget, 200)
        self.OwnerTeam.TeamMove:SetMemberMoveTarget(Role, ResultLoc, true)
    end
end

function TB_Fight:AsgnTarget(Army)
    log.dev('TB_Fight:AsgnTarget() 找目标喽！！！')
    local Enemy = self.OwnerTeam.TeamEnemy
    Enemy:SortEnemyByDist()
    -- local avatar = Enemy.tbEnemyRolePerception[1].Role.Avatar
    -- UE.UKismetSystemLibrary.DrawDebugSphere(avatar, avatar:K2_GetActorLocation(), 100, 12, UE.FLinearColor(0, 0, 1), 1.5, 4)
    for i, ele in ipairs(Army[FightPosDef.Frontline]) do
        local Role = ele ---@type RoleClass
        if not Enemy.tbEnemyRolePerception[i] then
            break
        end
        Role.BT.Blackboard:SetBBValue('FightTarget', Enemy.tbEnemyRolePerception[i].Role)
    end
    Enemy.FireTarget = Enemy.tbEnemyRolePerception[1].Role
end

--[[
to ChatGPT:
现在我考虑在战斗位置和战斗职业（法师战士等）和战场位置（前排后排等）两个定义中废除一个，因为我在写分配逻辑中有这样存在：
角色配置了可承担的职业，根据职业计算出可承担的位置，根据Team此时的位置的人的情况确定是否在此位置，然后得出了位置再反向
计算出职业，但是问题来了，有的职业可以对应很多位置，比如战斗法师可以前排也可以后排也可以承担游走等位置，所以多对多的情
况下及其混乱而且无法硕源，所以我现在考虑只给角色配置可承担的战斗位置，然后战斗职业作为人物描述写在desc_text_content中，
体现在该角色策划配置的技能都是某职业的技能，将一个业务逻辑问题转换为一个策划工种的配置问题
]]