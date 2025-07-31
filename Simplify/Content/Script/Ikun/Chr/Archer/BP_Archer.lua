
---
---@brief   主角-弓箭手
---@author  zys
---@data    Thu Jul 31 2025 23:26:44 GMT+0800 (中国标准时间)
---

---@class BP_Archer: BP_Archer_C
local BP_Archer = UnLua.Class('Ikun/Chr/Blueprint/BP_ChrBase')

-- function BP_Archer:Initialize(Initializer)
-- end

-- function BP_Archer:UserConstructionScript()
-- end

-- function BP_Archer:ReceiveBeginPlay()
-- end

-- function BP_Archer:ReceiveEndPlay()
-- end

-- function BP_Archer:ReceiveTick(DeltaSeconds)
-- end

-- function BP_Archer:ReceiveAnyDamage(Damage, DamageType, InstigatedBy, DamageCauser)
-- end

-- function BP_Archer:ReceiveActorBeginOverlap(OtherActor)
-- end

-- function BP_Archer:ReceiveActorEndOverlap(OtherActor)
-- end

function BP_Archer:LeftStart()
    log.dev('BP_Archer:LeftStart()')
    self.Mesh:GetAnimInstance().bPullingBow = true
end
function BP_Archer:LeftEnd()
    log.dev('BP_Archer:LeftEnd()')
    self.Mesh:GetAnimInstance().bPullingBow = false
end

return BP_Archer
