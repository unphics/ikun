
---
---@brief   道具
---@author  zys
---@data    Wed Aug 27 2025 00:32:22 GMT+0800 (中国标准时间)
---

---@class ItemBaseConfig
---@field ItemId number
---@field ItemName string
---@field ItemDesc string
---@field ItemType number
---@field StackNum number
---@field ItemSubtype number
---@field SpecialId number

---@class ItemBaseClass
---@field ItemId number 全局唯一id(对于同为消耗品,不同获得途径不进行合并)
---@field ItemCfgId number 配置表id
local ItemBaseClass = class.class 'ItemBaseClass' {
    ctor = function()end,
    ItemId = nil,
    ItemCfgId = nil,
    ItemCount = nil,
}

---@overide
function ItemBaseClass:ctor(ItemId, ItemCfgId, ItemCount)
    self.ItemId = ItemId
    self.ItemCfgId = ItemCfgId
    self.ItemCount = ItemCount or 1
end

return ItemBaseClass