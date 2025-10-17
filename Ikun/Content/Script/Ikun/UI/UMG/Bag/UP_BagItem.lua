
---
---@brief   背包界面Item
---@author  zys
---@data    Sat Oct 18 2025 01:46:55 GMT+0800 (中国标准时间)
---

---@class UP_Item: UP_Item_C
local UP_Item = UnLua.Class()

---@override
-- function UP_Item:Construct()
-- end

---@override
-- function UP_Item:Destruct()
-- end

---@override
--function UP_Item:Tick(MyGeometry, InDeltaTime)
--end

---@override
function UP_Item:OnListItemObjectSet(ListItemObject)
    self.ItemValue = ListItemObject.Value
    local config = ConfigMgr:GetConfig('Item')[self.ItemValue.ItemCfgId]
    self.TxtName:SetText(config.ItemName)
end

---@override
function UP_Item:BP_OnEntryReleased()
end

return UP_Item
