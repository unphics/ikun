
---
---@brief   背包界面Item
---@author  zys
---@data    Sat Oct 18 2025 01:46:55 GMT+0800 (中国标准时间)
---

---@class UP_Item: UP_Item_C
local UP_Item = UnLua.Class()

---@override
function UP_Item:Construct()
    self.BtnItem.OnClicked:Add(self, self._OnBtnItemClicked)
    self.BtnItem.OnHovered:Add(self, self._OnBtnItemHovered)
end

---@override
function UP_Item:Destruct()
    self.BtnItem.OnClicked:Clear()
    self.BtnItem.OnHovered:Clear()
end

---@override
function UP_Item:OnListItemObjectSet(ListItemObject)
    self.ItemValue = ListItemObject.Value
    local config = ConfigMgr:GetConfig('Item')[self.ItemValue.ItemCfgId]
    local name = config.ItemName
    if config.StackNum > 1 then
        name = name .. '(' .. self.ItemValue.ItemCount .. ')'
    end
    self.TxtName:SetText(name)
end

---@override
function UP_Item:BP_OnEntryReleased()
    self.ItemValue = nil
end

---@private
function UP_Item:_OnBtnItemClicked()
    if self.ItemValue.OwnerUI and self.ItemValue.ItemCfgId then
        self.ItemValue.OwnerUI._OnItemClicked(self.ItemValue.OwnerUI, self.ItemValue.ItemCfgId)
    end
end

---@private
function UP_Item:_OnBtnItemHovered()
    if self.ItemValue.OwnerUI and self.ItemValue.ItemCfgId then
        self.ItemValue.OwnerUI._OnItemHovered(self.ItemValue.OwnerUI, self.ItemValue.ItemCfgId)
    end
end

return UP_Item
