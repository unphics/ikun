
local QuestTool = require('Content/Quest/QuestTool')

---@class DynaSelect
local DynaSelect = {}

---@param NpcChat NpcChatClass
---@param SelectData ChatConfig
DynaSelect.CalcSelectInfo = function(NpcChat, SelectData)
    if SelectData.Content == 'Task1' then
        local target = NpcChat.ChatTarget
        local quests = target.QuestGiver:GetAvailableQuest()
        if quests[1] then
            QuestTool.IsFirstStepTalk(quests[1].QuestId)
            return { Content = '接受任务: 测试任务1' }
        end
    end
    return {Content = SelectData.Content}
end

return DynaSelect