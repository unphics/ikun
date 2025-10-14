
---
---@brief   物品背包
---@author  zys
---@data    Wed Aug 27 2025 00:45:13 GMT+0800 (中国标准时间)
---

---@alias ItemChangeCallback fun(table:table, ItemCfgId: id, Count: count, ItemId: id)

---@class BagClass
---@field private _ItemContainer table<id, ItemBaseClass> @物品容器<ItemId,物品对象>
---@field private _Owner RoleClass 拥有者
---@field private _OnItemAdd table[] 添加物品
---@field private _OnItemRemove table[] 移除物品
local BagClass = class.class 'BagClass' {}

---@public
---@param Owner RoleClass
function BagClass:ctor(Owner)
    self._Owner = Owner
    self._ItemContainer = {}
    self._OnItemAdd = {}
    self._OnItemRemove = {}
end

---@public 添加物品
---@param Item ItemBaseClass
function BagClass:AddItem(Item)
    -- local cfg = ConfigMgr:GetConfig('Item')[Item.ItemCfgId] ---@type ItemBaseConfig
    self._ItemContainer[Item.ItemId] = Item
    local count = Item.ItemCount or 1
    for _, ele in pairs(self._OnItemAdd) do
        if ele.Obj and ele.Fn then
            ele.Fn(ele.Obj, Item.ItemCfgId, count, Item.ItemId)
        end
    end
end

---@public
---@param ItemId id
---@return boolean
function BagClass:RemoveItem(ItemId)
    if not self._ItemContainer[ItemId] then
        return false
    end
    local item = self._ItemContainer[ItemId]
    self._ItemContainer[ItemId] = nil
    -- 回调通知
    for _, ele in pairs(self._OnItemRemove) do
        if ele.Obj and ele.Fn then
            ele.Fn(ele.Obj, item.ItemCfgId, item.ItemCount, item.ItemId)
        end
    end
    return true
end


---@public 批量移除物品
---@param ItemCfgId id
---@param Count count
---@return boolean
function BagClass:RemoveItems(ItemCfgId, Count)
    if not self:CanRemoveItems(ItemCfgId, Count) then
        log.error('BagClass:RemoveItems() 没有足够的物品移除')
        return false
    end

    local removed = 0 ---@type count
    ---@param item ItemBaseClass
    for _, item in pairs(self._ItemContainer)do
        if item.ItemCfgId == ItemCfgId and removed < Count then
            local removeCount = math.min(item.ItemCount, Count - removed)
    
            if item.ItemCount == removeCount then
                self._ItemContainer[item.ItemId] = nil
            else
                item.ItemCount = item.ItemCount - removeCount
            end
    
            removed = removed + removeCount
        end
        if removed >= Count then
            break
        end
    end
    -- 回调通知
    for _, ele in pairs(self._OnItemRemove) do
        if ele.Obj and ele.Fn then
            ele.Fn(ele.Obj, ItemCfgId, removed)
        end
    end
    return true
end

---@public [Pure] 判断是否可以移除一个此物品
---@param ItemCfgId id
---@param Count count
---@return boolean
function BagClass:CanRemoveItems(ItemCfgId, Count)
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

---@public [Pure] 获取此物品的数量
---@param ItemCfgId id
---@return count
function BagClass:GetItemCount(ItemCfgId)
    local total = 0
    for _, item in pairs(self._ItemContainer) do
        if item.ItemCfgId == ItemCfgId then
            total = total + (item.ItemCount or 1)
        end
    end
    return total
end

---@public 移动一类物品到其他背包中
---@param Count count
---@param TargetBag BagClass
---@return boolean
function BagClass:TransferItems(ItemCfgId, Count, TargetBag)
    ---@todo 提供更多预检查, 如CanRemove和CanAccept
    if not TargetBag or Count <= 0 then
        return false
    end
    local moved = 0
    for ItemId, item in pairs(self._ItemContainer) do
        if item.ItemCfgId == ItemCfgId and moved < Count then
            local moveCount = math.min(item.ItemCount, Count - moved)

            if item.ItemCount == moveCount then
                -- 移动整个物品
                self._ItemContainer[ItemId] = nil
                TargetBag:AddItem(item)
            else
                -- 分割物品
                item.ItemCount = item.ItemCount - moveCount
                local movedItem = ItemMgr:CreateItem(item.ItemCfgId, moveCount) -- 移动时创建新Id
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
    for _, ele in pairs(TargetBag._OnItemAdd) do
        if ele.Obj and ele.Fn then
            ele.Fn(ele.Obj, ItemCfgId, moved)
        end
    end
    return true
end

---@public [Register] 注册物品添加回调
---@param Obj table
---@param Fn ItemChangeCallback
function BagClass:RegItemAdd(Obj, Fn)
    if not  Obj or not Fn then
        log.fatal('BagClass:RegItemAdd() 无效的参数', Obj, Fn)
        return
    end
    table.insert(self._OnItemAdd, make_weak({Obj = Obj, Fn = Fn})) 
end

---@public [Register] 反注册物品添加回调
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

---@public [Register] 注册物品移除回调
---@param Fn ItemChangeCallback
function BagClass:RegItemRemove(Obj, Fn)
    if not Obj or not Fn then
        log.fatal('BagClass:RegItemRemove() 无效的参数', Obj, Fn)
        return
    end
    table.insert(self._OnItemRemove, make_weak({Obj = Obj, Fn = Fn})) 
end

---@public [Register] 反注册物品移除回调
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