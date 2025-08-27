
---
---@brief   背包
---@author  zys
---@data    Wed Aug 27 2025 00:45:13 GMT+0800 (中国标准时间)
---

---@class BagClass
---@field _ItemContainer table<number, ItemBaseClass>
---@field _Owner RoleClass
local BagClass = class.class 'BagClass' {
    ctor = function()end,
    AddItem = function()end,
    RemoveItem = function()end,
    _ItemContainer = nil,
    _Owner = nil,
}

---@override
function BagClass:ctor(Owner)
    self._Owner = Owner
    self._ItemContainer = {}
end

---@public
---@param Item ItemBaseClass
function BagClass:AddItem(Item)
    local cfg = MdMgr.ConfigMgr:GetConfig('Item')[Item.ItemCfgId] ---@type ItemBaseConfig
    self._ItemContainer[Item.ItemId] = Item
end

---@public
function BagClass:RemoveItem(ItemId, Count)
    local item = self._ItemContainer[ItemId] ---@type ItemBaseClass
    if not item then
        return false
    end
    local cfgId = item.ItemCfgId
    if item.ItemCount > Count then
        item.ItemCount = item.ItemCount - Count
        return true
    else
        Count = Count - item.ItemCount
        for _, ele in pairs(self._ItemContainer) do
            if ele.ItemCfgId == cfgId then
                if ele.ItemCount > Count then
                    ele.ItemCount = ele.ItemCount - Count
                    return true
                else
                    Count = Count - ele.ItemCount
                    self._ItemContainer[ele.ItemId] = nil
                    if Count <= 0 then
                        return true
                    end
                end
            end
        end
    end
end

return BagClass