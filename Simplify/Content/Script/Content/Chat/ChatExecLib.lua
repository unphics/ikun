
---
---@brief   对话执行库
---@author  zys
---@data    Fri Aug 29 2025 22:54:01 GMT+0800 (中国标准时间)
---

---@class ChatExecLib
local ChatExecLib = {}

---@public
---@param OwnerNpcChat NpcChatClass
ChatExecLib.TryExec = function(OwnerNpcChat, ExecData)
    if ExecData and ChatExecLib['_'..ExecData.Code] then
        ChatExecLib['_'..ExecData.Code](OwnerNpcChat, ExecData)
    else
        log.error('ChatExecLib.TryExec', '未知的执行代码', ExecData.Code)
    end
end

---@private
---@param OwnerNpcChat NpcChatClass
ChatExecLib._DoEndChat = function(OwnerNpcChat, ExecData)
    OwnerNpcChat:GetChatComp():EndChat()
end

---@private
---@param OwnerNpcChat NpcChatClass
ChatExecLib._QuestStart = function(OwnerNpcChat, ExecData)
    local ownerRole = OwnerNpcChat:GetChatOwner()
    ownerRole.QuestComp:StartQuest(ExecData.Param.QuestId)
end

---@private
---@param OwnerNpcChat NpcChatClass
ChatExecLib._QuestStep = function(OwnerNpcChat, ExecData)
    local ownerRole = OwnerNpcChat:GetChatOwner()
    ownerRole.QuestComp:TryCompleteStep(ExecData.Param.QuestStep)
end

return ChatExecLib