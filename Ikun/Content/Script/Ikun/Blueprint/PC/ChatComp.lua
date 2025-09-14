
---
---@brief   对话组件
---@author  zys
---@data    Wed Aug 27 2025 14:25:04 GMT+0800 (中国标准时间)
---

---@class ChatComp: BP_ChatComp_C
local ChatComp = UnLua.Class()

function ChatComp:ReceiveBeginPlay()
end

-- function ChatComp:ReceiveEndPlay()
-- end

-- function ChatComp:ReceiveTick(DeltaSeconds)
-- end

---@public [Server]
function ChatComp:BeginChat()
    self:S2C_BeginChat()
    self:_GetNpcChat():NewChat(40011, self:GetOwner().InteractComp.Rep_InteractActor)
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
    self:GetOwner().InteractComp:QuitInteract()
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
        ui:ShowSelectList(selectList)
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

function ChatComp:_GetNpcChat()
    local ownerChr = self:GetOwner().OwnerChr
    local ownerRole = rolelib.role(ownerChr)
    if ownerRole and ownerRole.NpcChat then
        return ownerRole.NpcChat
    end
    return nil
end

function ChatComp:S2C_ShowQuestMsg_RPC(QuestName, QuestState)
    local ui = ui_util.uimgr:ShowUI(ui_util.uidef.UI_QuestMsg) ---@type UI_QuestMsg
    log.dev('ui', ui)
    if ui then
        ui:SetQuestMsg(QuestName, QuestState)
    end
end

return ChatComp