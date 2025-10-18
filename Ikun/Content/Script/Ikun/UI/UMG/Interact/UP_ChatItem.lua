
---
---@brief   对话界面的条目
---@author  zys
---@data    Sat Oct 18 2025 21:29:17 GMT+0800 (中国标准时间)
---

---@class UP_InteractItem: UP_InteractItem_C
local UP_InteractItem = UnLua.Class()

---@override
function UP_InteractItem:Construct()
    self.BtnSelectItem.OnClicked:Add(self, self._OnBtnSelectItemClicked)
    self.BtnSelectItem.OnHovered:Add(self, self._OnBtnSelectItemHovered)
    self.BtnSelectItem.OnUnhovered:Add(self, self._OnBtnSelectItemUnhovered)
end

---@override
function UP_InteractItem:Destruct()
    self.BtnSelectItem.OnClicked:Clear()
    self.BtnSelectItem.OnHovered:Clear()
    self.BtnSelectItem.OnUnhovered:Clear()
end

---@override
function UP_InteractItem:OnListItemObjectSet(ItemData)
    self.ItemData = ItemData.Value
    self.TxtSelectItem:SetText(ItemData.Value.Content)
    if ItemData.Value.bSelected then
        self.ImgSelect:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    else
        self.ImgSelect:SetVisibility(UE.ESlateVisibility.Hidden)
    end
end

---@override
function UP_InteractItem:BP_OnEntryReleased()
    self.ItemData = nil
end

function UP_InteractItem:_OnBtnSelectItemClicked()
    if self.ItemData and self.ItemData.FnDoSelectIndex then
        self.ItemData.FnDoSelectIndex(self.ItemData.OwnerUI, self.ItemData.NextId)
    end
end

function UP_InteractItem:_OnBtnSelectItemHovered()
    if self.ItemData and self.ItemData.FnChatScrollIndex then    
        self.ItemData.FnChatScrollIndex(self.ItemData.OwnerUI, self.ItemData.Index)
    end
end

function UP_InteractItem:_OnBtnSelectItemUnhovered()
    if self.ItemData and self.ItemData.FnChatScrollIndex then    
        self.ItemData.FnChatScrollIndex(self.ItemData.OwnerUI, nil)
    end
end

return UP_InteractItem