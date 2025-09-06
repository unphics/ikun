
---
---@brief   投射物
---@author  zys
---@data    Sat Sep 06 2025 12:30:40 GMT+0800 (中国标准时间)
---

---@class BP_ProjectileBase: BP_ProjectileBase_C
local BP_ProjectileBase = UnLua.Class()

-- function BP_ProjectileBase:Initialize(Initializer)
-- end

-- function BP_ProjectileBase:UserConstructionScript()
-- end

-- function BP_ProjectileBase:ReceiveBeginPlay()
-- end

-- function BP_ProjectileBase:ReceiveEndPlay()
-- end

function BP_ProjectileBase:ReceiveTick(DeltaSeconds)
    -- self:DrawArrowPath(DeltaSeconds)
end

-- function BP_ProjectileBase:ReceiveAnyDamage(Damage, DamageType, InstigatedBy, DamageCauser)
-- end

-- function BP_ProjectileBase:ReceiveActorBeginOverlap(OtherActor)
-- end

-- function BP_ProjectileBase:ReceiveActorEndOverlap(OtherActor)
-- end

---@private 绘制箭矢的路径
function BP_ProjectileBase:DrawArrowPath(DeltaTime)
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

return BP_ProjectileBase