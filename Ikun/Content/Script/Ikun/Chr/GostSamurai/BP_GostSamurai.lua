--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--
local ERotMode = UE.UObject.Load('/Game/Ikun/Anim/Blueprint/Enum/RotMode.RotMode')

---@type BP_GhostSamurai_C
local M = UnLua.Class('/Ikun/Chr/Blueprint/BP_ChrBase')

-- function M:Initialize(Initializer)
-- end

-- function M:UserConstructionScript()
-- end

function M:ReceiveBeginPlay()
    self.AnimComp.RotMode = ERotMode.LookDir
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
