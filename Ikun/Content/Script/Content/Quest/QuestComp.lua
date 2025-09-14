
---
---@brief   任务组件
---@author  zys
---@data    Thu Aug 28 2025 22:43:09 GMT+0800 (中国标准时间)
---

---@class QuestCompClass
---@field _Owner RoleClass
---@field _Quests QuestInstClass[]
local QuestCompClass = class.class 'QuestCompClass' {
    ctor = function()end,
    StartQuest = function()end,
    _Owner = nil,
    _Quests = nil,
}

function QuestCompClass:ctor(Owner)
    self._Owner = Owner
    self._Quests = {}
end

function QuestCompClass:StartQuest(QuestId)
    if self:GetQuestInstById(QuestId) then
        log.warn('QuestCompClass:StartQuest', '任务已存在, 无法重复接取', QuestId)
        return
    end
    local questInst = class.new 'QuestInstClass'(self._Owner, QuestId)
    table.insert(self._Quests, questInst)
end

function QuestCompClass:TryCompleteStep(StepId)
    -- log.info('QuestCompClass:TryComplete', '尝试完成任务步骤', StepId)
    for _, quest in ipairs(self._Quests) do
        if quest:IsInProgress() and quest:GetCurStep() == StepId then
            log.info('QuestCompClass:TryComplete', '任务步骤完成!', StepId)
            quest:CompleteCurStep()
        end
    end
end

---@public [Pure]
---@return QuestInstClass | nil
function QuestCompClass:GetQuestInstById(QuestId)
    for _, quest in ipairs(self._Quests) do
        if quest.QuestId == QuestId then
            return quest
        end
    end
    return nil
end

return  QuestCompClass