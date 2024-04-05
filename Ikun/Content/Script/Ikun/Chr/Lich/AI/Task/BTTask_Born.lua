--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--

---@class BTTask_Born: BTTask_Born_C
local BTTask_Born = UnLua.Class()

function BTTask_Born:ReceiveExecuteAI(OwnerController, ControlledPawn)
    local BB = UE.UAIBlueprintHelperLibrary.GetBlackboard(OwnerController)
    
    self:FinishExecute(true)
end

return BTTask_Born