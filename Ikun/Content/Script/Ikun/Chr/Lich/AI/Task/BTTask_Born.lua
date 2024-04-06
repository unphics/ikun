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

    local TagContainer = UE.FGameplayTagContainer()
    TagContainer.GameplayTags:Add(UE.UIkunFuncLib.RequestGameplayTag('Chr.Skill.Born'))
    if not ControlledPawn:GetAbilitySystemComponent():TryActivateAbilitiesByTag(TagContainer) then
        log.error('failed to activate born')
    end
    local GA = gas_util.find_active_by_container(ControlledPawn, TagContainer)

    if GA then
        self.BornChr = ControlledPawn
        GA.OnAbilityEnd:Add(self, self.OnAbilityEnd)
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

--[[

void URPGAbilitySystemComponent::GetActiveAbilitiesWithTags(const FGameplayTagContainer& GameplayTagContainer, TArray<URPGGameplayAbility*>& ActiveAbilities)
{
	TArray<FGameplayAbilitySpec*> AbilitiesToActivate;
	GetActivatableGameplayAbilitySpecsByAllMatchingTags(GameplayTagContainer, AbilitiesToActivate, false);

	// Iterate the list of all ability specs
	for (FGameplayAbilitySpec* Spec : AbilitiesToActivate)
	{
		// Iterate all instances on this ability spec
		TArray<UGameplayAbility*> AbilityInstances = Spec->GetAbilityInstances();

		for (UGameplayAbility* ActiveAbility : AbilityInstances)
		{
			ActiveAbilities.Add(Cast<URPGGameplayAbility>(ActiveAbility));
		}
	}
}

]]