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
    self:InitMainUI()
    if self:HasAuthority() then

    else

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

function M:InitMainUI()
    local MainHudClass = UE.UClass.Load('/Game/Ikun/UI/UMG/MainHud/UIMainHud.UIMainHud_C')
    if not MainHudClass then
        log.error('GameStateInitMainUI', 'Failed to Load MainHud')
        return
    end
    local Widget = UE.UWidgetBlueprintLibrary.Create(self, MainHudClass, UE.UGameplayStatics.GetPlayerController(self, 0))
    if not Widget then
        log.error('GameStateInitMainUI', 'Failed to Create MainHud Widget')
        return
    end
    Widget:AddToViewport(0)
    Widget:InitUI(self:HasAuthority() and 'Server' or 'Client')
end

return M
