---
---@brief 对话广播界面
---@author zys
---@data Sun Apr 06 2025 10:35:40 GMT+0800 (中国标准时间)
---

---@class UI_TalkList: UI_TalkList_C
---@field TalkingRoleList table<string, TalkListItem>
---@field TalkingContentList TalkListItem[]
local M = UnLua.Class()

--function M:Initialize(Initializer)
--end

--function M:PreConstruct(IsDesignTime)
--end

function M:Construct()
    self.TalkingRoleList = {}
    self.TalkingContentList = {}
end

--function M:Tick(MyGeometry, InDeltaTime)
--end

---@public
function M:PushNewContent(Name, Content, Duration, Callback)
    if self.TalkingRoleList[Name] then
        log.error('当前角色正在说话中, 说完前一句话才能说第二句 : ', Name, Content)
        return false
    end
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
function M:UpdateTalkList()
    ui_util.set_list_items(self.TalkList, self.TalkingContentList)
end

---@private [ItemCall]
---@param ItemData TalkListItem
function M:OnItemTalkFinsih(ItemData)
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

return M
