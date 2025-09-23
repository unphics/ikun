
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
    CanRemoveItem = function()end,
    MoveItemToBag = function()end,
    GetItemCount = function()end,
    RegItemAdd = function()end,
    UnRegItemAdd = function()end,
    RegItemRemove = function()end,
    UnRegItemRemove = function()end,
    _ItemContainer = nil,
    _Owner = nil,
    _OnItemAdd = nil,
    _OnItemRemove = nil,
}

---@override
function BagClass:ctor(Owner)
    self._Owner = Owner
    self._ItemContainer = {}
    self._OnItemAdd = {}
    self._OnItemRemove = {}
end

---@public
---@param Item ItemBaseClass
function BagClass:AddItem(Item)
    local cfg = ConfigMgr:GetConfig('Item')[Item.ItemCfgId] ---@type ItemBaseConfig
    self._ItemContainer[Item.ItemId] = Item
    local count = Item.ItemCount or 1
    for _, ele in pairs(self._OnItemAdd) do
        if ele.Obj and ele.Fn then
            ele.Fn(ele.Obj, Item.ItemCfgId, count)
        end
    end
end

---@public
function BagClass:RemoveItem(ItemId, Count)
local item = self._ItemContainer[ItemId] ---@type ItemBaseClass
    if not item then
        return
    end
    local cfgId = item.ItemCfgId
    local removed = 0
    if item.ItemCount > Count then
        item.ItemCount = item.ItemCount - Count
        removed = Count
    else
        removed = item.ItemCount
        Count = Count - item.ItemCount
        self._ItemContainer[ItemId] = nil
        for _, ele in pairs(self._ItemContainer) do
            if ele.ItemCfgId == cfgId and Count > 0 then
                if ele.ItemCount > Count then
                    ele.ItemCount = ele.ItemCount - Count
                    removed = removed + Count
                    Count = 0
                else
                    removed = removed + ele.ItemCount
                    Count = Count - ele.ItemCount
                    self._ItemContainer[ele.ItemId] = nil
                end
            end
            if Count <= 0 then
                break
            end
        end
    end
    -- 回调通知
    for _, ele in pairs(self._OnItemRemove) do
        if ele.Obj and ele.Fn then
            ele.Fn(ele.Obj, cfgId, removed)
        end
    end
end

---@public [Pure]
function BagClass:CanRemoveItem(ItemCfgId, Count)
    local total = 0
    for _, item in pairs(self._ItemContainer) do
        if item.ItemCfgId == ItemCfgId then
            total = total + (item.ItemCount or 1)
            if total >= Count then
                return true
            end
        end
    end
    return false
end

---@public [Pure]
function BagClass:GetItemCount(ItemCfgId)
    local total = 0
    for _, item in pairs(self._ItemContainer) do
        if item.ItemCfgId == ItemCfgId then
            total = total + (item.ItemCount or 1)
        end
    end
    return total
end

---@public
---@param TargetBag BagClass
function BagClass:MoveItemToBag(ItemCfgId, Count, TargetBag)
 if not TargetBag or Count <= 0 then
        return
    end
    local moved = 0
    for ItemId, item in pairs(self._ItemContainer) do
        if item.ItemCfgId == ItemCfgId and moved < Count then
            local moveCount = math.min(item.ItemCount, Count - moved)
            if item.ItemCount == moveCount then
                TargetBag:AddItem(item)
                self._ItemContainer[ItemId] = nil
            else
                item.ItemCount = item.ItemCount - moveCount
                local ItemBaseClass = require("Content.Item.ItemBase")
                local movedItem = ItemBaseClass(item.ItemId, item.ItemCfgId, moveCount)
                TargetBag:AddItem(movedItem)
            end
            moved = moved + moveCount
        end
        if moved >= Count then
            break
        end
    end
    -- 回调通知
    for _, ele in pairs(self._OnItemRemove) do
        if ele.Obj and ele.Fn then
            ele.Fn(ele.Obj, ItemCfgId, moved)
        end
    end
    -- for _, ele in pairs(TargetBag._OnItemAdd) do
    --     if ele.Obj and ele.Fn then
    --         ele.Fn(ele.Obj, ItemCfgId, moved)
    --     end
    -- end
end

---@public [Register]
function BagClass:RegItemAdd(Obj, Fn)
    if Obj and Fn then
       table.insert(self._OnItemAdd, {Obj = Obj, Fn = Fn}) 
    end
end
---@public [Register]
function BagClass:UnRegItemAdd(Obj)
    if Obj then
        for i, ele in ipairs(self._OnItemAdd) do
            if ele.Obj == Obj then
                table.remove(self._OnItemAdd, i)
                break
            end
        end
    end
end
---@public [Register]
function BagClass:RegItemRemove(Obj, Fn)
    if Obj and Fn then
       table.insert(self._OnItemRemove, {Obj = Obj, Fn = Fn}) 
    end 
end
---@public [Register]
function BagClass:UnRegItemRemove(Obj)
    if Obj then
        for i, ele in ipairs(self._OnItemRemove) do
            if ele.Obj == Obj then
                table.remove(self._OnItemRemove, i)
                break
            end
        end
    end
end

return BagClass