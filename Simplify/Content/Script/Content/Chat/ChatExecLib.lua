
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