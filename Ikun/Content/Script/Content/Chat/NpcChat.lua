
---
---@brief   NPC对话
---@author  zys
---@data    Thu Aug 28 2025 23:58:24 GMT+0800 (中国标准时间)
---

local ChatExecLib = require('Content/Chat/ChatExecLib')
local DynaSelect = require('Content/Chat/DynaSelect')


---@class ChatConfig
---@field Id number
---@field Type number
---@field Cond number
---@field Content string
---@field NextId number
---@field Select number[]
---@field PreExecId number
---@field PostExecId number

---@class NpcChatClass
---@field _Owner RoleClass
---@field _CurChatId number
---@field _CurSelectList number[]
---@field ChatTarget RoleClass
local NpcChatClass = class.class 'NpcChatClass' {
    ctor = function()end,
    NewChat = function()end,
    UpdateChat = function()end,
    DoSelectIndex = function()end,
    DoTalkNext = function()end,
    GetChatOwner = function()end,
    GetChatData = function()end,
    GetChatComp = function()end,
    _Owner = nil,
    _CurChatId = nil,
    _CurSelectList = nil,
    ChatTarget = nil,
}

function NpcChatClass:ctor(Owner)
    self._Owner = Owner
end

---@public
function NpcChatClass:NewChat(ChatId, Target)
    self._CurChatId = ChatId
    self._CurSelectList = nil
    self.ChatTarget = rolelib.role(Target)
    self:UpdateChat()
end

---@public
function NpcChatClass:UpdateChat()
    local data = self:GetChatData(self._CurChatId)
        if not data then
        return log.error('NpcChatClass:UpdateChat()', '无效的ChatId', self._CurChatId)
    end
    log.info('NpcChatClass:UpdateChat() 当前ChatId', self._CurChatId)
    if data.PreExecId then
        local execData = MdMgr.ConfigMgr:GetConfig('ChatExec')[data.PreExecId]
        ChatExecLib.TryExec(self, execData)
    end
    if data.Type == 1 or data.Type == 3 then
        self:GetChatComp():S2C_ShowTalkContent(data.Content)
    elseif data.Type == 2 then
        self._CurSelectList = data.Select
        local selectList = {}
        for _, id in ipairs(self._CurSelectList) do
            local selectData = self:GetChatData(id)
            table.insert(selectList, selectData.Content)
        end
        self:GetChatComp():S2C_ShowSelectList(selectList)
    elseif data.Type == 4 then -- 动态选项
        self._CurSelectList = {}
        for _, id in ipairs(data.Select) do
            local selectData = self:GetChatData(id)
            local selectIds = DynaSelect.CalcSelectInfo(self, selectData)
            for _, id in ipairs(selectIds) do
                table.insert(self._CurSelectList, id)
            end
        end
        local selectList = {}
        for _, id in ipairs(self._CurSelectList) do
            local selectData = self:GetChatData(id)
            table.insert(selectList, selectData.Content)
        end
        if #selectList == 0 then -- 没有任何选项
            return
        end
        self:GetChatComp():S2C_ShowSelectList(selectList)
    end
end

---@public
function NpcChatClass:DoSelectIndex(Index)
    local curSelectId = self._CurSelectList[Index]
    local data = self:GetChatData(curSelectId)
    if data.PostExecId then
        local execData = MdMgr.ConfigMgr:GetConfig('ChatExec')[data.PostExecId]
        ChatExecLib.TryExec(self, execData)
    end
    self._CurChatId = data.NextId
    self:UpdateChat()
end

---@public
function NpcChatClass:DoTalkNext()
    local data = self:GetChatData(self._CurChatId)
    if data then
        if data.PostExecId then
            local execData = MdMgr.ConfigMgr:GetConfig('ChatExec')[data.PostExecId]
            ChatExecLib.TryExec(self, execData)
        end
        self._CurChatId = data.NextId
        self:UpdateChat()
    end
end

---@public [Pure]
---@return ChatConfig
function NpcChatClass:GetChatData(ChatId)
    local config = MdMgr.ConfigMgr:GetConfig('Chat')
    local data = config[ChatId]
    if not data then
        log.error('NpcChatClass:GetChatData()', '无效的ChatId', ChatId)
    end
    return data
end

---@public [Pure] [Comp]
function NpcChatClass:GetChatComp()
    return self._Owner.Avatar:GetController().ChatComp
end

---@public [Pure]
---@return RoleClass
function NpcChatClass:GetChatOwner()
    return self._Owner
end

return NpcChatClass