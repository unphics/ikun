--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--

local IkunChrClass = UE.UClass.Load('/Game/Ikun/Chr/Blueprint/BP_ChrBase.BP_ChrBase_C')

local AlertDistance = 1000

---@type BTService_Patrol_C
local M = UnLua.Class()

function M:ReceiveActivationAI(OwnerController, ControlledPawn)
    -- 每次行为树从Root刷新时执行一次
end

function M:ReceiveTickAI(OwnerController, ControlledPawn, DeltaSeconds)
    local NearbyActor, NearbyDistance = actor_util.get_nearby_ikun_chr(ControlledPawn)
    if NearbyActor then
        if NearbyDistance < AlertDistance then
            local BB = UE.UAIBlueprintHelperLibrary.GetBlackboard(OwnerController)
            BB:SetValueAsObject('NearbyActor', NearbyActor)
            self:CheckNearbyActor(OwnerController, ControlledPawn, NearbyActor)
        end
    end
end

---@private 判断是否进入战斗或者未来有新的状态
function M:CheckNearbyActor(OwnerController, ControlledPawn, NearbyActor)
    if not gas_util.asc_has_tag_by_name(ControlledPawn, 'Chr.State.InFight') then
        gas_util.asc_add_tag_by_name(ControlledPawn, 'Chr.State.InFight')
        local BB = UE.UAIBlueprintHelperLibrary.GetBlackboard(OwnerController)
        BB:SetValueAsObject('FightTargetActor', NearbyActor)
        OwnerController:StopMovement()
        log.warn('lich begin fight')
    end
end

return M