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
    self.BtnSelectItem.OnHovered:Add(self, self.OnBtnSelectItemHovered)
    self.BtnSelectItem.OnUnhovered:Add(self, self.OnBtnSelectItemUnhovered)
end

function M:Destruct()
    self.BtnSelectItem.OnClicked:Clear()
    self.BtnSelectItem.OnHovered:Clear()
    self.BtnSelectItem.OnUnhovered:Clear()
end

--function M:Tick(MyGeometry, InDeltaTime)
--end

function M:OnListItemObjectSet(ItemData)
    self.TxtSelectItem:SetText(ItemData.Value.Content)
    self.ItemData = ItemData.Value
    if ItemData.Value.bSelected then
        self.ImgSelect:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    else
        self.ImgSelect:SetVisibility(UE.ESlateVisibility.Hidden)
    end
end

function M:OnBtnSelectItemClicked()
    if self.ItemData and self.ItemData.DoSelectIndex then
        self.ItemData.DoSelectIndex(self.ItemData.OwnerUI, self.ItemData.NextId)
    end
end

function M:OnBtnSelectItemHovered()
    if self.ItemData and self.ItemData.SelectIndex then    
        self.ItemData.ScrollIndex(self.ItemData.OwnerUI, self.ItemData.Index)
    end
end

function M:OnBtnSelectItemUnhovered()
    if self.ItemData and self.ItemData.SelectIndex then    
        self.ItemData.ScrollIndex(self.ItemData.OwnerUI, nil)
    end
end

return M