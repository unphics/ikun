--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--

local RandomNavRadius = 1000

---@class BTTask_SearchPatrolLoc: BTTask_SearchPatrolLoc_C
local BTTask_SearchPatrolLoc = UnLua.Class()

function BTTask_SearchPatrolLoc:ReceiveExecuteAI(OwnerController, ControlledPawn)
    local BB = UE.UAIBlueprintHelperLibrary.GetBlackboard(OwnerController)
    if BB then
        local Pos = UE.FVector()
        UE.UNavigationSystemV1.K2_GetRandomReachablePointInRadius(ControlledPawn, ControlledPawn.StrongholdLoc, Pos, RandomNavRadius, nil, nil)
        BB:SetValueAsVector('PatrolLoc', Pos)
        -- log.error('BTTask_SearchPatrolLoc', ControlledPawn.StrongholdLoc, Pos)
        self:FinishExecute(true)
        return
    end
    self:FinishExecute(false)
end

return BTTask_SearchPatrolLoc