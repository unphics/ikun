
---
---@brief   NPC对话
---@author  zys
---@data    Thu Aug 28 2025 23:58:24 GMT+0800 (中国标准时间)
---

local ChatExecLib = require('Content/Chat/ChatExecLib')
local DynaSelect = require('Content/Chat/DynaSelect')

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
    _GetChatData = function()end,
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
    local data = self:_GetChatData(self._CurChatId)
        if not data then
        return log.error('NpcChatClass:UpdateChat()', '无效的ChatId', self._CurChatId)
    end
    if data.Type == 1 or data.Type == 3 then
        if data.PreExecId then
            local code = MdMgr.ConfigMgr:GetConfig('ChatExec')[data.PreExecId].Code
            ChatExecLib.TryExec(self, code)
        end
        self:GetChatComp():S2C_ShowTalkContent(data.Content)
    elseif data.Type == 2 then
        self._CurSelectList = data.Select
        local selectList = {}
        for _, id in ipairs(self._CurSelectList) do
            local selectData = self:_GetChatData(id)
            table.insert(selectList, selectData.Content)
        end
        self:GetChatComp():S2C_ShowSelectList(selectList)
    elseif data.Type == 4 then -- 动态选项
        self._CurSelectList = {}
        for _, id in ipairs(data.Select) do
            local selectData = self:_GetChatData(id)
            local selectIds = DynaSelect.CalcSelectInfo(self, selectData)
            for _, id in ipairs(selectIds) do
                table.insert(self._CurSelectList, id)
            end
        end
        local selectList = {}
        for _, id in ipairs(self._CurSelectList) do
            local selectData = self:_GetChatData(id)
            table.insert(selectList, selectData.Content)
        end
        self:GetChatComp():S2C_ShowSelectList(selectList)
    end
end

---@public
function NpcChatClass:DoSelectIndex(Index)
    local curSelectId = self._CurSelectList[Index]
    local data = self:_GetChatData(curSelectId)
    self._CurChatId = data.NextId
    self:UpdateChat()
end

---@public
function NpcChatClass:DoTalkNext()
    local data = self:_GetChatData(self._CurChatId)
    if data then
        self._CurChatId = data.NextId
        self:UpdateChat()
    end
end

---@private [Pure]
---@return ChatConfig
function NpcChatClass:_GetChatData(ChatId)
    local config = MdMgr.ConfigMgr:GetConfig('Chat')
    return config[ChatId]
end

---@public [Pure] [Comp]
function NpcChatClass:GetChatComp()
    return self._Owner.Avatar:GetController().ChatComp
end

return NpcChatClass