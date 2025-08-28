
---@class QuestTool
local QuestTool = {}

QuestTool.IsFirstStepTalk = function(QuestId)
    local config = MdMgr.QuestMgr:GetQuestConfigById(QuestId)
    
    return false
end

return QuestTool