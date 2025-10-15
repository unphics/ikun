
---
---@brief   玩家背包组件
---@author  zys
---@data    Wed Oct 15 2025 23:44:49 GMT+0800 (中国标准时间)
---

---@class BP_BagComp: BP_BagComp_C
local BP_BagComp = UnLua.Class()

---@override
function BP_BagComp:ReceiveBeginPlay()
    gameinit.registerinit(gameinit.ring.four, self, self._InitBagComp)
end

---@override
function BP_BagComp:ReceiveEndPlay()
    local role = self:GetOwner().GetRole and self:GetOwner():GetRole() ---@type RoleClass
    if role then
        role.Bag:UnRegItemAdd(self)
        role.Bag:UnRegItemRemove(self)
    end
end

-- function BP_BagComp:ReceiveTick(DeltaSeconds)
-- end

---@private [Init]
function BP_BagComp:_InitBagComp()
    local role = self:GetOwner().GetRole and self:GetOwner():GetRole() ---@type RoleClass
    if not role then
        log.error('BP_BagComp:_InitBagComp() 初始化失败')
        return
    end
    role.Bag:RegItemAdd(self, self._OnItemAdd)
    role.Bag:RegItemRemove(self, self._OnItemRemove)
end

---@private [Callback]
---@param ItemCfgId id
---@param ItemCount count
---@param ItemId id
function BP_BagComp:_OnItemAdd(ItemCfgId, ItemCount, ItemId)
end

---@private [Callback]
---@param ItemCfgId id
---@param ItemCount count
---@param ItemId id
function BP_BagComp:_OnItemRemove(ItemCfgId, ItemCount, ItemId)
end

---@private [Data]
function BP_BagComp:_SyncBagData()
end

return BP_BagComp