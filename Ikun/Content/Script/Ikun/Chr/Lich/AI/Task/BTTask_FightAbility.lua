--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--

---@type BTTask_FightAbility_C
local M = UnLua.Class()

function M:ReceiveExecuteAI(OwnerController, ControlledPawn)
    self.Overridden.ReceiveExecuteAI(self, OwnerController, ControlledPawn)

    local BB = UE.UAIBlueprintHelperLibrary.GetBlackboard(OwnerController)
    local FightTargetActor = BB:GetValueAsObject('FightTargetActor')
    local DecisionAbilityInfo = BB:GetValueAsObject('DecisionAbilityInfo')

    if not DecisionAbilityInfo then
        log.error('failed to read ability info')
        self:FinishExecute(false)
        return
    end

    if not ControlledPawn:GetAbilitySystemComponent():TryActivateAbility(DecisionAbilityInfo.Handle) then
        log.error('failed to activate fight ability')
        self:FinishExecute(false)
        return
    end
    
    local GA = gas_util.find_active_by_name(ControlledPawn, DecisionAbilityInfo.TagName)
    if not GA then
        log.error('failed to find activated ability')
        self:FinishExecute(false)
        return
    end

    self.OwnerChr = ControlledPawn
    GA.OnAbilityEnd:Add(self, self.OnAbilityEnd)
end

function M:OnAbilityEnd(Result)
    
    self:FinishExecute(Result)
end

return M