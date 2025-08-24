--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--

---@class UP_InteractItem: UP_InteractItem_C
local M = UnLua.Class()

function M:Construct()
    self.BtnSelectItem.OnClicked:Add(self, self.OnBtnSelectItemClicked)
end

function M:Destruct()
    self.BtnSelectItem.OnClicked:Clear()
end

--function M:Tick(MyGeometry, InDeltaTime)
--end

function M:OnListItemObjectSet(ItemData)
    self.TxtSelectItem:SetText(ItemData.Value.Content)
    self.ItemData = ItemData.Value
end

function M:OnBtnSelectItemClicked()
    if self.ItemData and self.ItemData.OnItemClicked then
        self.ItemData.OnItemClicked(self.ItemData.OwnerUI, self.ItemData.NextId)
    end
end

return M