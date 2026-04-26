
---
---@brief   物品
---@author  zys
---@data    Wed Aug 27 2025 00:32:22 GMT+0800 (中国标准时间)
---

local log =  require("Core/Log/log")

---@class ItemConfig
---@field ItemId integer
---@field ItemName string
---@field ItemDesc string
---@field ItemType integer
---@field StackNum integer
---@field ItemSubtype integer
---@field SpecialId integer
---@field ItemTemplate string

---@class ItemBaseClass 物品类
---@field ItemId integer 全局唯一id(对于同为消耗品,不同获得途径不进行合并)
---@field ItemCfgId integer 物品配置表id
---@field ItemCount integer 物品数量
local ItemBaseClass = class.class 'ItemBaseClass' {}

---@public
---@param ItemId integer
---@param ItemCfgId integer
---@param ItemCount integer
function ItemBaseClass:ctor(ItemId, ItemCfgId, ItemCount)
    self.ItemId = ItemId
    self.ItemCfgId = ItemCfgId
    self.ItemCount = ItemCount or 1
end

---@public 使用物品
function ItemBaseClass:UseItem(OwnerRole, Count)
    log.info(log.key.item, '物品模块使用物品', self.ItemId, self.ItemCfgId, Count)
end

return ItemBaseClass