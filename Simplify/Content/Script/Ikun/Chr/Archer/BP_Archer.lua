
---
---@brief   主角-弓箭手
---@author  zys
---@data    Thu Jul 31 2025 23:26:44 GMT+0800 (中国标准时间)
---

local ArrowClass = UE.UClass.Load('/Game/Ikun/Chr/Archer/BP_Arrow.BP_Arrow_C')

---@class BP_Archer: BP_Archer_C
local BP_Archer = UnLua.Class('Ikun/Chr/Blueprint/BP_ChrBase')

-- function BP_Archer:Initialize(Initializer)
-- end

-- function BP_Archer:UserConstructionScript()
-- end

---@override
function BP_Archer:ReceiveBeginPlay()
    self.Overridden.ReceiveBeginPlay(self)
    -- if net_util.is_server(self) then
    --     self.ASC.OnTagChanged:Add(self, self.OnASCTagChanged)
    -- end
end

-- function BP_Archer:ReceiveEndPlay()
-- end

---@override
function BP_Archer:ReceiveTick(DeltaSeconds)
    self.Overridden.ReceiveTick(self, DeltaSeconds)
end

-- function BP_Archer:ReceiveAnyDamage(Damage, DamageType, InstigatedBy, DamageCauser)
-- end

-- function BP_Archer:ReceiveActorBeginOverlap(OtherActor)
-- end

-- function BP_Archer:ReceiveActorEndOverlap(OtherActor)
-- end

function BP_Archer:C2S_LeftStart_RPC()
    self.bPullingBow = true
end
function BP_Archer:C2S_LeftEnd_RPC()
    self.bPullingBow = false
end

-- function BP_Archer:OnASCTagChanged(GameplayTag, bExist)
--     if GameplayTag.TagName == UE.UIkunFnLib.RequestGameplayTag('Skill.Tag.Shoot').TagName then
--         log.dev('qqqqqqqqqqqqqq')
--         local locBow = self.Bow:GetSocketLocation('Bow_String') -- self.Bow:GetSocketTransform('Bow_String', UE.ERelativeTransformSpace.RTS_World)
--         local rotChr = self:K2_GetActorRotation()
--         actor_util.spawn_always(self, ArrowClass, UE.FTransform(rotChr:ToQuat(), locBow))
--     end
-- end

function BP_Archer:ArcherShoot()
    local locBow = self.Bow:GetSocketLocation('Bow_String') -- self.Bow:GetSocketTransform('Bow_String', UE.ERelativeTransformSpace.RTS_World)
    local rotChr = self:K2_GetActorRotation()
    self:C2S_ArcherShoot(UE.FTransform(rotChr:ToQuat(), locBow))
end

function BP_Archer:C2S_ArcherShoot_RPC(trans)
    actor_util.spawn_always(self, ArrowClass, trans)
end

return BP_Archer