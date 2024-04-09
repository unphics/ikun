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
    self.Overridden.ReceiveExecuteAI(self, OwnerController, ControlledPawn)

    -- 记录出生点(据点)
    ControlledPawn.StrongholdLoc = ControlledPawn:K2_GetActorLocation()

    local TagContainer = UE.FGameplayTagContainer()
    TagContainer.GameplayTags:Add(UE.UIkunFuncLib.RequestGameplayTag('Chr.Skill.Born'))
    if not ControlledPawn:GetAbilitySystemComponent():TryActivateAbilitiesByTag(TagContainer) then
        log.error('failed to activate born')
        self:FinishExecute(false)
        return 
    end
    local GA = gas_util.find_active_by_container(ControlledPawn, TagContainer)

    if GA then
        self.BornChr = ControlledPawn
        GA.OnAbilityEnd:Add(self, self.OnAbilityEnd)
        log.log('wait ability exec')
    else
        log.error('failed to find activated ability')
        self:FinishExecute(false)
    end
end

function BTTask_Born:OnAbilityEnd(Result)
    -- self.Overridden.OnAbilityEnd(self, Result)

    gas_util.asc_add_tag_by_name(self.BornChr, 'Chr.State.Born')

    self:FinishExecute(Result)
end

return BTTask_Born