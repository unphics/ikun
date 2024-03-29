local MdMgr = require('Ikun.Module.MdMgr')

---@type BP_IkunGameModeBase_C
local M = UnLua.Class()

-- function M:Initialize(Initializer)
-- end

function M:UserConstructionScript()
    MdMgr:Init()
end

function M:ReceiveBeginPlay()
    log.log('game mode base: ReceiveBeginPlay ')
end

-- function M:ReceiveEndPlay()
-- end

function M:ReceiveTick(DeltaSeconds)
    MdMgr:Tick(DeltaSeconds)
end

-- function M:ReceiveAnyDamage(Damage, DamageType, InstigatedBy, DamageCauser)
-- end

-- function M:ReceiveActorBeginOverlap(OtherActor)
-- end

-- function M:ReceiveActorEndOverlap(OtherActor)
-- end

return M
