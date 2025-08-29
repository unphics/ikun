
---
---@brief   动态对话
---@author  zys
---@data    Fri Aug 29 2025 22:54:01 GMT+0800 (中国标准时间)
---

---@class ChatExecLib
local ChatExecLib = {}

---@public
---@param NpcChat NpcChatClass
ChatExecLib.TryExec = function(NpcChat, Code)
    if Code and ChatExecLib['_'..Code] then
        ChatExecLib['_'..Code](NpcChat)
    end
end

---@private
---@param NpcChat NpcChatClass
ChatExecLib._DoEndChat = function(NpcChat)
    NpcChat:GetChatComp():EndChat()
end

return ChatExecLib