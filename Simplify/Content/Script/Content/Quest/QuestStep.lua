---
---@brief   任务步骤
---@author  zys
---@date    Wed Aug 27 2025 11:02:21 GMT+0800 (中国标准时间)
---

---@class QuestStepClass
---@field StepCfgId number 步骤配置Id
---@field OwnerQuest QuestClass 所属任务实例
---@field OwnerRole RoleClass 所属角色实例
---@field State string 步骤状态（如'init'/'doing'/'done'）
---@field Progress number 步骤进度
local QuestStepClass = class.class 'QuestStepClass' {
    ctor = function()end,
    StepCfgId = 0,
    OwnerQuest = nil,
    OwnerRole = nil,
    State = 'init',
    Progress = 0,
}

function QuestStepClass:ctor(stepCfgId, ownerQuest, ownerRole)
    self.StepCfgId = stepCfgId or 0
    self.OwnerQuest = ownerQuest
    self.OwnerRole = ownerRole
    self.State = 'init'
    self.Progress = 0
end

function QuestStepClass:GetCfg()
    return QuestStepCfg and QuestStepCfg[self.StepCfgId] or nil
end

function QuestStepClass:CheckCondition()
    local cfg = self:GetCfg()
    if not cfg or not cfg.ConditionId then return true end
    -- 可扩展：根据 ConditionId 查询条件表并判断
    return true
end

function QuestStepClass:IsCompleted()
    local cfg = self:GetCfg()
    if not cfg then return false end
    -- 可扩展：根据 StepType、Count、Param 等判定
    return self.State == 'done'
end

function QuestStepClass:OnStepEvent(event, ...)
    -- 根据事件类型处理
end

return QuestStepClass
