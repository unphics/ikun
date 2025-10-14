
---
---@brief   物品
---@author  zys
---@data    Wed Aug 27 2025 00:32:22 GMT+0800 (中国标准时间)
---

---@class ItemBaseConfig
---@field ItemId id
---@field ItemName name
---@field ItemDesc string
---@field ItemType integer
---@field StackNum count
---@field ItemSubtype integer
---@field SpecialId id

---@class ItemBaseClass 物品类
---@field ItemId id 全局唯一id(对于同为消耗品,不同获得途径不进行合并)
---@field ItemCfgId id 物品配置表id
---@field ItemCount count 物品数量
local ItemBaseClass = class.class 'ItemBaseClass' {}

---@public
---@param ItemId id
---@param ItemCfgId id
---@param ItemCount count
function ItemBaseClass:ctor(ItemId, ItemCfgId, ItemCount)
    self.ItemId = ItemId
    self.ItemCfgId = ItemCfgId
    self.ItemCount = ItemCount or 1
end

return ItemBaseClass