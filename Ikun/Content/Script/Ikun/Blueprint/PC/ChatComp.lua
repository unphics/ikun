
---
---@brief   对话组件
---@author  zys
---@data    Wed Aug 27 2025 14:25:04 GMT+0800 (中国标准时间)
---

---@class ChatComp: BP_ChatComp_C
local ChatComp = UnLua.Class()

---@public [Server]
function ChatComp:BeginChat()
    self:S2C_BeginChat()
    self:_GetNpcChat():NewChat(400011, self:_GetInteractComp():GetInteractTarget())
    return true
end

---@private [Client]
function ChatComp:S2C_BeginChat_RPC()
    ui_util.uimgr:ShowUI(ui_util.uidef.Chat)
end

---@public [Server]
function ChatComp:C2S_ReqEndChat_RPC()
    self:EndChat()
end

---@public [Server]
function ChatComp:EndChat()
    self:S2C_EndChat()
    self:_GetInteractComp():QuitInteract()
end

---@private [Client]
function ChatComp:S2C_EndChat_RPC()
    ui_util.uimgr:HideUI(ui_util.uidef.Chat)
end

---@private [Client]
function ChatComp:S2C_ShowSelectList_RPC(SelectList)
    local ui = ui_util.uimgr:GetUIIfVisible(ui_util.uidef.Chat) ---@type Chat
    if ui then
        local selectList = SelectList:ToTable() 
        ui:SetSelectListData(selectList)
    end
end

---@private [Client]
function ChatComp:S2C_ShowTalkContent_RPC(Content)
    local ui = ui_util.uimgr:GetUIIfVisible(ui_util.uidef.Chat)
    if ui then
        ui:ShowTalkContent(Content)
    end
end

---@public [Server]
function ChatComp:C2S_DoSelectIndex_RPC(Index)
    self:_GetNpcChat():DoSelectIndex(Index)
end

---@public [Server]
function ChatComp:C2S_TalkNext_RPC()
    self:_GetNpcChat():DoTalkNext()
end

---@private 获取对话对象
function ChatComp:_GetNpcChat()
    local ownerChr = self:GetOwner().OwnerChr
    local ownerRole = rolelib.role(ownerChr)
    if ownerRole and ownerRole.NpcChat then
        return ownerRole.NpcChat
    end
    return nil
end

---@public 显示任务Tips
function ChatComp:S2C_ShowQuestMsg_RPC(QuestName, QuestState)
    local ui = ui_util.uimgr:ShowUI(ui_util.uidef.UI_QuestMsg) ---@type UI_QuestMsg
    if ui then
        ui:SetQuestMsg(QuestName, QuestState)
    end
end

---@private
function ChatComp:_GetInteractComp()
    return self:GetOwner().InteractComp
end

return ChatComp