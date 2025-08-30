
---
---@brief   物件管理器
---@author zys
---@data   Thu Aug 28 2025 01:27:23 GMT+0800 (中国标准时间)
---

require('Content/Item/ItemBase')
require('Content/Item/Bag')

---@class ItemMgr: MdBase
local ItemMgr = class.class"ItemMgr": extends 'MdBase'{
    ctor = function()end,
    Init = function()end,
    _AllItem = nil,
    _NextItemId = nil,
}

function ItemMgr:ctor()
    self._AllItem = {}
    self._NextItemId = 1
end

---@public
---@return ItemBaseClass
function ItemMgr:CreateItem(ItemCfgId, Count)
    local id = self._NextItemId
    self._NextItemId = self._NextItemId + 1
    local item = class.new'ItemBaseClass'(id, ItemCfgId, Count) ---@type ItemBaseClass
    self._AllItem[id] = item
    return item
end

function ItemMgr:GetItem(ItemId)
    return self._AllItem[ItemId]
end

return ItemMgr