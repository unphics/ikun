
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
    ---@step 初步给出站位(根据方向, 防御性站位)
    ---@step 延迟一下
    ---@step 分析敌方角色
    ---@step 打或跑(暂时默认打)
    
    ---@step 给出进一步站位(进攻性)
    ---@step 后排给出集火目标, 前排给出对线目标
end

---@private 分配战斗角色
function TB_Fight:AssignFightCareer()
    -- 首先对于只能担任固定职业的角色则固定分配
    -- 对于可以灵活分配职业的角色则后排比前排稍多
    ---@todo 暂时只有Lich一只怪, 暂定固定一些写法
    local Army = {}
    for enum, _ in pairs(FightPositionDef) do
        Army[enum] = {}
    end
    local AssignRate = {} -- 默认的最佳配比
    AssignRate[FightPositionDef.Frontline] = 1
    AssignRate[FightPositionDef.Backline] = 2

    local IsArmyNeedCareer = function(Army, ECareerDef)
        
    end
    
    local ArrSingleCareer, ArrMultiCarrer = self.OwnerTeam.TeamMember:GetAllMember_CareerCount()
    ---@todo 优先处理只能承担单一职业的角色
    ---@todo 只能承担单一战斗职业的略过
    ---@todo 根据默认的最佳配比初步分配角色
    for _, ele in ipairs(ArrMultiCarrer) do
        local Role = ele ---@type RoleClass
        local tbFightCareerAssign = RoleConfig[Role.RoleConfigId].FightCareerAssign
        
        local HpRatio = 1 ---@todo cur_hp / max_hp
        local bForceBackline = HpRatio < 0.2
        ---@step (if 有得跑 or 有牧师)血量极少, 强制后排
        ---@step 血量较少, 优先后排
        ---@step 根据这场战斗的战场位置评估分配率决定
        
    end
end