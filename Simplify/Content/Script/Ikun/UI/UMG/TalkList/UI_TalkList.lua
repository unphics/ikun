
---
---@brief   对话广播界面
---@author  zys
---@data    Sun Apr 06 2025 10:35:40 GMT+0800 (中国标准时间)
---

---@class UI_TalkList: UI_TalkList_C
---@field TalkingRoleList table<string, TalkListItem>
---@field TalkingContentList TalkListItem[]
local UI_TalkList = UnLua.Class()

---@override
function UI_TalkList:Construct()
    self.TalkingRoleList = {}
    self.TalkingContentList = {}
    self:Test()
end

---@override
function UI_TalkList:Tick(MyGeometry, InDeltaTime)
end

---@public
---@param Name string 人名
---@param Content string 内容
---@param Duration number 持续时间
---@param Callback fun() 播放完成的回调
function UI_TalkList:PushContent(Name, Content, Duration, Callback)
    -- if self.TalkingRoleList[Name] then
    --     log.error('当前角色正在说话中, 说完前一句话才能说第二句 : ', Name, Content)
    --     return false
    -- end
    ---@class TalkListItem
    local Item = {
        Name = Name,
        Content = Content,
        Duration = Duration or 3,
        Callback = Callback,
        OwnerUI = self,
        CurTime = 0,
    }
    self.TalkingRoleList[Name] = Item
    table.insert(self.TalkingContentList, Item)
    self:UpdateTalkList()
    return true
end

---@private
function UI_TalkList:UpdateTalkList()
    ui_util.set_list_items(self.TalkList, self.TalkingContentList)
end

---@private [ItemCall]
---@param ItemData TalkListItem
function UI_TalkList:OnItemTalkFinsih(ItemData)
    self.TalkingRoleList[ItemData.Name] = nil
    local Index = -1
    for i, ele in ipairs(self.TalkingContentList) do
        if ele.Name == ItemData.Name then
            Index = i
            break
        end
    end
    table.remove(self.TalkingContentList, Index)
    self:UpdateTalkList()
end

---@private
function UI_TalkList:Test()
    self.test_idx = 1
    local talkConfig = MdMgr.ConfigMgr:GetConfig('Talk')
    local len = table_util.map_len(talkConfig)
    async_util.timer(self, function()
        ---@todo 此处不该直接硬编码47000
        local data = talkConfig[47000 + self.test_idx]
        self.test_idx = self.test_idx + 1
        if self.test_idx > len then
            self.test_idx = 1
        end
        self:PushContent(data.TalkerName, data.TalkContent, 8)
    end, 5, true)
end

return UI_TalkList