---
---@brief   任务实例
---@author  zys
---@data    Wed Aug 27 2025 10:50:42 GMT+0800 (中国标准时间)
---

local QuestStateType = require('Content/Quest/QuestStateType')

---@class QuestConfig
---@field QuestId number
---@field Title string
---@field Desc string 
---@field BeginStep number
---@field AcceptNpc number
---@field CompleteNpc number
---@field PreQuest number[]
---@field NextQuest number[]
---@field Repeatable number
---@field ExpireTime number
---@field RewardId number

---@class QuestInstClass
---@field QuestId number
---@field _Owner RoleClass
---@field QuestState QuestStateType
---@field _CurStep number
local QuestInstClass = class.class 'QuestInstClass' {
    ctor = function()end,
    IsInProgress = function()end,
    QuestId = nil,
    QuestState = nil,
    _Owner = nil,
    _CurStep = nil,
}

---@public
function QuestInstClass:ctor(Owner, QuestId)
    self._Owner = Owner
    self.QuestId = QuestId
    self.QuestState = QuestStateType.InProgress
    local config = self:GetQuestConfig()
    self._CurStep = config.BeginStep
    log.info('QuestInstClass:ctor()', '任务开始!', QuestId, config.Title)

    local role = rolelib.role(self._Owner)
    if role and role.Avatar and obj_util.is_valid(role.Avatar) then
        local pc = role.Avatar:GetController()
        pc.ChatComp:S2C_ShowQuestMsg(self:GetQuestConfig().Title, '任务开始')
    end
end

---@public
function QuestInstClass:CompleteCurStep()
    -- complete
    -- next
    local stepCfg = MdMgr.QuestMgr:GetQuestStepConfigById(self._CurStep)
    if stepCfg.NextStep then
        self._CurStep = stepCfg.NextStep
        log.info('QuestInstClass:CompleteCurStep()', '任务步骤完成, 进入下一步', self._CurStep)
    else
        self:CompleteQuest()
    end
end

---@public
function QuestInstClass:CompleteQuest()
    self.QuestState = QuestStateType.Completed
    log.info('QuestInstClass:CompleteCurStep()', '任务完成!', self.QuestId)

        local role = rolelib.role(self._Owner)
    if role and role.Avatar and obj_util.is_valid(role.Avatar) then
        local pc = role.Avatar:GetController()
        pc.ChatComp:S2C_ShowQuestMsg(self:GetQuestConfig().Title, '任务完成')
    end
end

---@public [Pure]
function QuestInstClass:GetCurStep()
    return self._CurStep
end

---@public [Pure]
function QuestInstClass:IsInProgress()
    return self.QuestState == QuestStateType.InProgress
end

---@public [Pure]
---@return QuestConfig | nil
function QuestInstClass:GetQuestConfig()
    local config = MdMgr.QuestMgr:GetQuestConfigById(self.QuestId)
    return config
end

return QuestInstClass