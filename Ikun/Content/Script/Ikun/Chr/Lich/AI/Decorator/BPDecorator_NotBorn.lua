--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--

---@type BTDecorator_NotBorn_C
local M = UnLua.Class()

function M:PerformConditionCheckAI(OwnerController, ControlledPawn)
    return not ControlledPawn:GetAbilitySystemComponent():HasGameplayTag(UE.UIkunFuncLib.RequestGameplayTag('Chr.State.Born'))
end

return M