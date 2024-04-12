--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--

---@type BTDecorator_ReadyFar_C
local M = UnLua.Class()

function M:PerformConditionCheckAI(OwnerController, ControlledPawn)
    local BB = UE.UAIBlueprintHelperLibrary.GetBlackboard(OwnerController)
    local DecisionAbilityInfo = BB:GetValueAsObject('DecisionAbilityInfo')
    return DecisionAbilityInfo.TagName == 'Chr.Skill.Far'
end

return M