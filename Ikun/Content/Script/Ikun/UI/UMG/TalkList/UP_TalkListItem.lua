---
---@brief 对话广播界面的列表元素
---@author zys
---@data Sun Apr 06 2025 10:35:40 GMT+0800 (中国标准时间)
---

---@class UP_TalkListItem: UP_TalkListItem_C
---@field ItemData TalkListItem
local M = UnLua.Class()

--function M:Initialize(Initializer)
--end

--function M:PreConstruct(IsDesignTime)
--end

-- function M:Construct()
-- end

function M:Tick(MyGeometry, InDeltaTime)
    if self.ItemData then
        self.ItemData.CurTime = self.ItemData.CurTime + InDeltaTime
        if self.ItemData.CurTime > self.ItemData.Duration then
            self:ThisTalkEnd()
        end
    end
end

function M:OnListItemObjectSet(InItem)
    local ItemData = InItem.Value
    self.TxtTalkContent:SetText(''..ItemData.Name..' :  '..ItemData.Content)
    self.ItemData = ItemData
end

function M:ThisTalkEnd()
    self.ItemData.OwnerUI:OnItemTalkFinsih(self.ItemData)
end

return M
