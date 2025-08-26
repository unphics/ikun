
---
---@brief   背包
---@author  zys
---@data    Wed Aug 27 2025 00:45:13 GMT+0800 (中国标准时间)
---

require('Content/Item/ItemBase')

---@class BagClass
---@field ItemContainer table<number, ItemBaseClass>
local BagClass = class.class 'BagClass' {
--[[public]]
    ctor = function()end,
--[[private]]
    ItemContainer = nil,
}

function BagClass:ctor()
    self.ItemContainer = {}
end

function BagClass:AddItem(Item)
end

function BagClass:RemoveItem(ItemId)
end

function BagClass:MoveItemToAnother(AnotherBag, Item)
    
end

function BagClass:GetItemById(ItemId)
end

function BagClass:GetItemByCfgId(ItemCfgId)
end

return BagClass