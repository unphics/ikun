
---
---@brief   聊天条件库
---@author  zys
---@data    Sat Aug 30 2025 01:33:14 GMT+0800 (中国标准时间)
---

---@class ChatCondConfig
---@field Id number
---@field Desc string
---@field Code string
---@field Params table

---@class ChatCondLib
local ChatCondLib = {}

---@public
---@param OwnerNpcChat NpcChatClass
---@param Cond number
function ChatCondLib.TryCheckCond(OwnerNpcChat, Cond)
    local data = ConfigMgr:GetConfig('ChatCond')[Cond] ---@type ChatCondConfig
    if data then
        if ChatCondLib['_'..data.Code] then
            return ChatCondLib['_'..data.Code](OwnerNpcChat, data)
        else
            log.error('ChatCondLib.TryCheckCond', '未知的条件代码', data.Code)
        end
    else
        log.error('ChatCondLib.TryCheckCond', '无效的条件Id', Cond)
    end
    return false
end

---@private 任务进行中
---@param OwnerNpcChat NpcChatClass
---@param CondConfig ChatCondConfig
function ChatCondLib._Quest(OwnerNpcChat, CondConfig)
    local ownerRole = OwnerNpcChat:GetChatOwner()
    local questId = CondConfig.Params.QuestId
    if questId and ownerRole and ownerRole.QuestComp then
        local questInst = ownerRole.QuestComp:GetQuestInstById(questId)
        if questInst and questInst:IsInProgress() then
            return true
        end
    end
    return false
end

---@private 任务接取了
---@param OwnerNpcChat NpcChatClass
---@param CondConfig ChatCondConfig
function ChatCondLib._QuestStart(OwnerNpcChat, CondConfig)
    local ownerRole = OwnerNpcChat:GetChatOwner()
    local questId = CondConfig.Params.QuestId
    if questId and ownerRole and ownerRole.QuestComp then
        local questInst = ownerRole.QuestComp:GetQuestInstById(questId)
        if questInst then
            return true
        end
    end
    return false
end

return ChatCondLib