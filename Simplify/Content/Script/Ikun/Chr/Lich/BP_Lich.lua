---
---@brief Lich 巫妖
---@author zys
---@data Tue Jan 14 2025 13:56:55 GMT+0800 (中国标准时间)
---

---@class BP_Lich: BP_Lich_C
local M = UnLua.Class('/Ikun/Chr/Blueprint/BP_ChrBase')

-- function M:Initialize(Initializer)
-- end

-- function M:UserConstructionScript()
-- end

---@protected [ImplBP]
function M:ReceiveBeginPlay()
    self.Super.ReceiveBeginPlay(self)
    ---@todo zys Lich的颜色
    -- self.MsgBusComp:RegEvent("ChrInitDisplay", self, self.InitLichColor)
end

-- function M:ReceiveEndPlay()
-- end

-- function M:ReceiveTick(DeltaSeconds)
-- end

-- function M:ReceiveAnyDamage(Damage, DamageType, InstigatedBy, DamageCauser)
-- end

-- function M:ReceiveActorBeginOverlap(OtherActor)
-- end

-- function M:ReceiveActorEndOverlap(OtherActor)
-- end

return M
