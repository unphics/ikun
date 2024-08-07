--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--

---@type BP_GameState_C
local M = UnLua.Class()

-- function M:Initialize(Initializer)
-- end

-- function M:UserConstructionScript()
-- end

function M:ReceiveBeginPlay()
    if self:HasAuthority() then
        log.log("GamePlay GameState ReceiveBeginPlay Server")
        world_util.GameWorld = self
        net_util.b_svr = true
    else
        log.log("GamePlay GameState ReceiveBeginPlay Client")
        world_util.GameWorld = self
        self:InitUIModule()
        net_util.b_svr = false
    end
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

function M:InitUIModule()
    local LayerMgrClass = UE.UClass.Load('/Game/Ikun/UI/UMG/LayerMgr.LayerMgr_C')
    local LayerMgr = UE.UWidgetBlueprintLibrary.Create(self, LayerMgrClass, UE.UGameplayStatics.GetPlayerController(self, 0))
    LayerMgr:AddToViewport(0)
end

return M
