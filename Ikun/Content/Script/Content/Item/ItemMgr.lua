
---
---@brief   物品管理器
---@author  zys
---@data    Thu Aug 28 2025 01:27:23 GMT+0800 (中国标准时间)
---

require('Content/Item/ItemBase')
require('Content/Item/Bag')

---@class ItemMgr
---@field _AllItem table<id, ItemBaseClass> 所有物品的索引
---@field _NextItemId id 下一此创建物品时的IdNum, 用来赋予物品全局唯一实例Id
local ItemMgr = class.class"ItemMgr"{
    ctor = function()end,
    CreateItem = function()end,
    GetItem = function()end,
    _AllItem = nil,
    _NextItemId = nil,
}

---@public
function ItemMgr:ctor()
    self._AllItem = {}
    self._NextItemId = 1
end

---@public 根据配置Id创建物品
---@param ItemCfgId id
---@param Count count
---@return ItemBaseClass
function ItemMgr:CreateItem(ItemCfgId, Count)
    local id = self._NextItemId
    self._NextItemId = self._NextItemId + 1
    local item = class.new'ItemBaseClass'(id, ItemCfgId, Count) ---@as ItemBaseClass
    self._AllItem[id] = item
    return item
end

---@public 根据实例Id获取物品
---@param ItemId id
---@return ItemBaseClass
function ItemMgr:GetItem(ItemId)
    return self._AllItem[ItemId]
end

return ItemMgr