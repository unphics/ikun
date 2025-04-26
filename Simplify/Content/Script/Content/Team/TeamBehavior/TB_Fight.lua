
---
---@brief 战斗行为
---@author zys
---@data Fri Apr 25 2025 22:27:17 GMT+0800 (中国标准时间)
---

local RoleConfig = require('Content/Role/Config/RoleConfig')
local BTType = require('Ikun.Module.AI.BT.BTType')

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

    ---@step 己方职业分化
    ---@step 初步给出站位(根据方向, 防御性站位)
    ---@step 延迟一下
    ---@step 分析敌方职业分化
    ---@step 打或跑(暂时默认打)
    
    ---@step 给出进一步站位(进攻性)
    ---@step 后排给出集火目标, 前排给出对线目标
end

---@private 分配战斗职业
function TB_Fight:AssignFightCareer()
    -- 首先对于只能担任固定职业的角色则固定分配
    -- 对于可以灵活分配职业的角色则后排比前排稍多
end