---
---@brief   任务
---@author  zys
---@data    Wed Aug 27 2025 10:50:42 GMT+0800 (中国标准时间)
---

---@class QuestClass
---@field QuestId number 任务示例Id
---@field QuestCfgId number 任务配置Id
---@field CurStepId number 当前步骤Id
---@field _Owner RoleClass
---@field StepList table 步骤列表
---@field IsCompleted boolean 是否完成
---@field RewardId number 奖励Id
local QuestClass = class.class 'QuestClass' {
    ctor = function()end,
    _Owner = nil,
    QuestId = 0,
    QuestCfgId = 0,
    CurStepId = 0,
    StepList = {},
    IsCompleted = false,
    RewardId = 0,
}

-- 构造函数，初始化任务
function QuestClass:ctor(Owner, questCfgId)
    self._Owner = Owner
    self.QuestCfgId = questCfgId or 0
    self:LoadQuestCfg(questCfgId)
end

-- 加载任务配置
function QuestClass:LoadQuestCfg(cfgId)
    -- 这里假设有全局表 QuestCfg, QuestStepCfg, QuestCondCfg
    local cfg = QuestCfg and QuestCfg[cfgId]
    if not cfg then return end
    self.QuestId = cfg.QuestId
    self.CurStepId = cfg.BeginStep
    self.RewardId = cfg.RewardId
    self.StepList = {}
    local stepId = cfg.BeginStep
    while stepId and QuestStepCfg and QuestStepCfg[stepId] do
        local step = QuestStepCfg[stepId]
        table.insert(self.StepList, step)
        stepId = step.NextStep
    end
end

-- 获取当前步骤
function QuestClass:GetCurStep()
    for _, step in ipairs(self.StepList) do
        if step.QuestStepId == self.CurStepId then
            return step
        end
    end
    return nil
end

-- 推进到下一步骤
function QuestClass:NextStep()
    local curStep = self:GetCurStep()
    if not curStep then return false end
    if curStep.NextStep and QuestStepCfg[curStep.NextStep] then
        self.CurStepId = curStep.NextStep
        return true
    else
        self:CompleteQuest()
        return false
    end
end

-- 检查当前步骤条件
function QuestClass:CheckCondition()
    local curStep = self:GetCurStep()
    if not curStep or not curStep.ConditionId then return true end
    local cond = QuestCondCfg and QuestCondCfg[curStep.ConditionId]
    if not cond then return true end
    -- 这里只做简单判断，具体可扩展
    if cond.QuestCondType == 'DialogChoice' then
        -- 假设有对话选择判断逻辑
        return true
    end
    return true
end

-- 完成任务
function QuestClass:CompleteQuest()
    self.IsCompleted = true
    self:GiveReward()
end

-- 发放奖励
function QuestClass:GiveReward()
    if self.RewardId and self._Owner and self._Owner.AddReward then
        self._Owner:AddReward(self.RewardId)
    end
end

return QuestClass