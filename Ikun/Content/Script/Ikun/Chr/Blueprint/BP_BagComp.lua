
---
---@brief   背包组件
---@author  zys
---@data    Wed Oct 15 2025 23:44:49 GMT+0800 (中国标准时间)
---@todo    优化数据同步, 挪到主Blueprint目录中
---

local BPS_Item = UE.UObject.Load('/Game/Ikun/Blueprint/Struct/BPS_Item.BPS_Item')

---@class BP_BagComp: BP_BagComp_C
local BP_BagComp = UnLua.Class()

---@override
function BP_BagComp:ReceiveBeginPlay()
    if net_util.is_server(self:GetOwner()) then
        gameinit.registerinit(gameinit.ring.four, self, self._InitBagComp)
    end
end

---@override
function BP_BagComp:ReceiveEndPlay()
    local avatar = self:GetOwner()
    local role = avatar.GetRole and avatar:GetRole() ---@type RoleClass
    if role then
        role.Bag:UnRegItemAdd(self)
        role.Bag:UnRegItemRemove(self)
    end
end

-- function BP_BagComp:ReceiveTick(DeltaSeconds)
-- end

---@private [Init]
function BP_BagComp:_InitBagComp()
    local avatar = self:GetOwner()
    local role = avatar.GetRole and avatar:GetRole() ---@type RoleClass
    if not role then
        log.error('BP_BagComp:_InitBagComp() 初始化失败')
        return
    end
    role.Bag:RegItemAdd(self, self._OnItemAdd)
    role.Bag:RegItemRemove(self, self._OnItemRemove)
    self:_SyncBagData()
end

---@private [Callback]
---@param ItemCfgId id
---@param ItemCount count
---@param ItemId id
function BP_BagComp:_OnItemAdd(ItemCfgId, ItemCount, ItemId)
    self:_SyncBagData()
end

---@private [Callback]
---@param ItemCfgId id
---@param ItemCount count
---@param ItemId id
function BP_BagComp:_OnItemRemove(ItemCfgId, ItemCount, ItemId)
    self:_SyncBagData()
end

---@private [Data] 立即同步所有物品到组件
function BP_BagComp:_SyncBagData()
    self.BagItems:Clear()
    local role = self:GetOwner().GetRole and self:GetOwner():GetRole() ---@type RoleClass
    local allItem = role.Bag:GetAllItems() ---@type ItemBaseClass[]
    for _, item in ipairs(allItem) do
        local struct = BPS_Item()
        struct.ItemId = item.ItemId
        struct.ItemCfgId = item.ItemCfgId
        struct.ItemCount = item.ItemCount
        self.BagItems:Add(struct)
    end
end

return BP_BagComp