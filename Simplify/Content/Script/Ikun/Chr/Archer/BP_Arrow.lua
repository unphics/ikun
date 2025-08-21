
---
---@brief   箭矢
---@author  zys
---@data    Tue Aug 12 2025 00:30:00 GMT+0800 (中国标准时间)
---

---@class BP_Arrow: BP_Arrow_C
local BP_Arrow = UnLua.Class()

-- function BP_Arrow:Initialize(Initializer)
-- end

-- function BP_Arrow:UserConstructionScript()
-- end

-- function BP_Arrow:ReceiveBeginPlay()
-- end

-- function BP_Arrow:ReceiveEndPlay()
-- end

function BP_Arrow:ReceiveTick(DeltaSeconds)
    -- self:DrawArrowPath(DeltaSeconds)
end

-- function BP_Arrow:ReceiveAnyDamage(Damage, DamageType, InstigatedBy, DamageCauser)
-- end

-- function BP_Arrow:ReceiveActorBeginOverlap(OtherActor)
-- end

-- function BP_Arrow:ReceiveActorEndOverlap(OtherActor)
-- end

---@private 绘制箭矢的路径
function BP_Arrow:DrawArrowPath(DeltaTime)
    if net_util.is_server(self) then
        return
    end
    local interval = 0.1
    if not self.curtime then
        self.curtime = DeltaTime
    else
        self.curtime = self.curtime + DeltaTime
    end
    if self.curtime > interval then
        self.curtime = self.curtime - interval
        UE.UKismetSystemLibrary.DrawDebugSphere(self, self:K2_GetActorLocation(), 40, 6, UE.FLinearColor(0, 0, 1), 10, 3)
    end
end

return BP_Arrow
