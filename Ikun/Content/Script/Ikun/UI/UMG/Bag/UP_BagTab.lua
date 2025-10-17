
---
---@brief   背包的Tab
---@author  zys
---@data    Sat Oct 18 2025 00:54:06 GMT+0800 (中国标准时间)
---

---@class UP_BagTab: UP_BagTab_C
local UP_BagTab = UnLua.Class()

---@override
function UP_BagTab:Construct()
    self.BtnTab.OnClicked:Add(self, self._OnBtnTabClicked)
end

---@override
function UP_BagTab:Destruct()
    self.BtnTab.OnClicked:Clear()
end

---@override
--function UP_BagTab:Tick(MyGeometry, InDeltaTime)
--end

---@override
function UP_BagTab:OnListItemObjectSet(ListItemObject)
    self.ItemValue = ListItemObject.Value
    self.TxtName:SetText(self.ItemValue.BagTabName)
    if self.ItemValue.BagTabId then
        self.BtnTab:SetVisibility(UE.ESlateVisibility.Visible)
    else
        self.BtnTab:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    end
    if self.ItemValue.OwnerUI and self.ItemValue.BagTabId == self.ItemValue.OwnerUI.BagTabId then
        self.ImgSelect:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    else
        self.ImgSelect:SetVisibility(UE.ESlateVisibility.Hidden)
    end
end

---@override
function UP_BagTab:BP_OnEntryReleased()
    self.ItemValue = nil
end

---@private
function UP_BagTab:_OnBtnTabClicked()
    if self.ItemValue and self.ItemValue.OwnerUI and self.ItemValue.BagTabId then
        self.ItemValue.OwnerUI._OnTabClicked(self.ItemValue.OwnerUI, self.ItemValue.BagTabId)
    end
end

return UP_BagTab