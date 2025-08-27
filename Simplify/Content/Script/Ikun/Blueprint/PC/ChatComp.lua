
---
---@brief   对话组件
---@author  zys
---@data    Wed Aug 27 2025 14:25:04 GMT+0800 (中国标准时间)
---

---@class ChatConfig
---@field Id number
---@field Type number
---@field Content string
---@field NextId number
---@field Select number[]
---@field PreExecId number
---@field PostExecId number

---@class ChatComp: BP_ChatComp_C
local ChatComp = UnLua.Class()

function ChatComp:ReceiveBeginPlay()
    self.CurChatId = nil
    self.CurSelectList = nil
end

-- function ChatComp:ReceiveEndPlay()
-- end

-- function ChatComp:ReceiveTick(DeltaSeconds)
-- end

---@public [Server]
function ChatComp:BeginChat()
    self.CurChatId = 41001
    self.CurSelectList = nil
    self:S2C_BeginChat()
    self:UpdateChat()
    return true
end

---@private [Client]
function ChatComp:S2C_BeginChat_RPC()
    ui_util.uimgr:ShowUI(ui_util.uidef.Chat)
end

---@public [Server]
function ChatComp:EndChat()
    self.CurChatId = nil
    self.CurSelectList = nil
    self:S2C_EndChat()
    self:GetOwner().InteractComp:QuitInteract()
end

---@private [Client]
function ChatComp:S2C_EndChat_RPC()
    ui_util.uimgr:HideUI(ui_util.uidef.Chat)
end

---@private [Server]
function ChatComp:UpdateChat()
    local data = self:GetChatData(self.CurChatId)
    if not data then
        return log.error('ChatComp:UpdateChat()', '无效的ChatId', self.CurChatId)
    end
    if data.Type == 1 then
        if data.PreExecId then
            local code = MdMgr.ConfigMgr:GetConfig('ChatExec')[data.PreExecId].Code
            if code and self['Exec_'..code] then
                self['Exec_'..code](self)
            end
        end
        self:S2C_ShowTalkContent(data.Content)
    elseif data.Type == 2 then
        self.CurSelectList = data.Select
        local selectList = {}
        for _, id in ipairs(self.CurSelectList) do
            local selectData = self:GetChatData(id)
            table.insert(selectList, selectData.Content)
        end
        self:S2C_ShowSelectList(selectList)
    end
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
    local curSelectId = self.CurSelectList[Index]
    local data = self:GetChatData(curSelectId)
    self.CurChatId = data.NextId
    self:UpdateChat()
end

---@public [Server]
function ChatComp:C2S_TalkNext_RPC()
    local data = self:GetChatData(self.CurChatId)
    if data then
        self.CurChatId = data.NextId
        self:UpdateChat()
    end
end

---@private [Server] [Pure]
---@return ChatConfig
function ChatComp:GetChatData(ChatId)
    local config = MdMgr.ConfigMgr:GetConfig('Chat')
    return config[ChatId]
end

---@private
function ChatComp:Exec_DoEndChat()
    self:EndChat()
end

return ChatComp