
---
---@brief 战斗行为
---@author zys
---@data Fri Apr 25 2025 22:27:17 GMT+0800 (中国标准时间)
---

local RoleConfig = require('Content/Role/Config/RoleConfig')
local FightCareerDef = require('Content/Role/FightCareerDef')
local BTType = require('Ikun.Module.AI.BT.BTType')
local FightPositionDef = require 'Content/Role/FightPositionDef'

---@class TB_Fight : TeamBehaviorBase
---
local TB_Fight = class.class 'TB_Fight' : extends 'TeamBehaviorBase' {
--[[public]]
    OnEncounterEnemy = function()end,
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

    ---@step 己方角色分化
    self:AssignFightCareer()
    ---@step 初步给出站位(根据方向, 防御性站位)
    ---@step 延迟一下
    ---@step 分析敌方角色
    ---@step 打或跑(暂时默认打)
    
    ---@step 给出进一步站位(进攻性)
    ---@step 后排给出集火目标, 前排给出对线目标
end

local DftFPAssignRate = {} -- 默认的最佳战场位置配比(default fight position assign rate)
DftFPAssignRate[FightPositionDef.Frontline] = 1
DftFPAssignRate[FightPositionDef.Backline] = 2

---@private 分配战斗角色
function TB_Fight:AssignFightCareer()
    -- 首先对于只能担任固定职业的角色则固定分配
    -- 对于可以灵活分配职业的角色则后排比前排稍多
    ---@todo 暂时只有Lich一只怪, 暂定固定一些写法

    local mapMaxFCCount = self.OwnerTeam.TeamMember:CalcMaxCountEachCareer()
    local mapFPAssignRate = {} -- 此时团队的职业比率
    local nSumFPRate = 0
    for def, rate in pairs(DftFPAssignRate) do
        if mapMaxFCCount[def] then
            mapFPAssignRate[def] = rate
            nSumFPRate = nSumFPRate + rate
        end
    end
    
    local Army = {} -- 众多战场位置组成的军队
    for enum, _ in pairs(FightPositionDef) do
        Army[enum] = {}
    end

    -- 军队此战场位置需要人
    ---@param Army table<FightPositionDef, RoleClass[]>
    ---@param FPDef FightPositionDef
    ---@param nStdFPRate number 此局此战场位置标准占比(此位置配给 : 总配给)
    local IsArmyNeedFP = function(Army, FPDef, nStdFPRate)
        local Total = 0
        for def, arrRole in pairs(Army) do
            Total = Total + #arrRole
        end
        return (Army[FPDef] / Total) > nStdFPRate
    end
    
    local ArrSingleFC, ArrMultiFC = self.OwnerTeam.TeamMember:GetAllMember_CareerCount()
    ---@todo 优先处理只能承担单一职业的角色
    ---@todo 只能承担单一战斗职业的略过
    ---@todo 根据默认的最佳配比初步分配角色
    for _, ele in ipairs(ArrMultiFC) do
        local Role = ele ---@type RoleClass
        local arrFCAssign = RoleConfig[Role.RoleConfigId].FightCareerAssign
        local FightPos = nil
        ---@todo (if 有得跑 or 有牧师)血量极少, 强制后排
        ---@todo 血量较少, 优先后排
        ---@step 根据这场战斗的战场位置评估分配率决定
        local arrFP = {FightPositionDef.Frontline, FightPositionDef.Backline} ---@todo 由规则函数处理 此角色可承担的战场位置, 根据此角色可承担的战斗职业配置
        for _, FP in ipairs(arrFP) do
            if IsArmyNeedFP(Army, FP, mapFPAssignRate[FP] / nSumFPRate) then
                FightPos = FP
                break 
            end
        end
        
    end
end
--[[
to ChatGPT:
现在我考虑在战斗位置和战斗职业（法师战士等）和战场位置（前排后排等）两个定义中废除一个，因为我在写分配逻辑中有这样存在：
角色配置了可承担的职业，根据职业计算出可承担的位置，根据Team此时的位置的人的情况确定是否在此位置，然后得出了位置再反向
计算出职业，但是问题来了，有的职业可以对应很多位置，比如战斗法师可以前排也可以后排也可以承担游走等位置，所以多对多的情
况下及其混乱而且无法硕源，所以我现在考虑只给角色配置可承担的战斗位置，然后战斗职业作为人物描述写在desc_text_content中，
体现在该角色策划配置的技能都是某职业的技能，将一个业务逻辑问题转换为一个策划工种的配置问题
]]