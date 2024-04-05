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

    -- ControlledPawn:BornTask(self)
    -- ControlledPawn.ASC:TryActivateAbility(ControlledPawn.GABornHandle)

    -- self:FinishExecute(true)

    local TagContainer = UE.FGameplayTagContainer()
    TagContainer.GameplayTags:Add(UE.UIkunFuncLib.RequestGameplayTag('Chr.Skill.Born'))
    if not ControlledPawn:GetAbilitySystemComponent():TryActivateAbilitiesByTag(TagContainer) then
        log.error('failed to activate born')
    end
    local GA = nil
    local Abilitys = UE.TArray(UE.UIkunGABase)
    ControlledPawn:GetAbilitySystemComponent():GetActivateAbilitiesWithTag(TagContainer, Abilitys)
    for _, Ability in pairs(Abilitys) do
        -- if Ability:HasMatchingGameplayTag(UE.UIkunFuncLib.RequestGameplayTag('Chr.Skill.Born')) then
        --     GA = Ability
        -- end
        local a = Ability.AbilityTags
    end
    -- GA.OnAbilityEnd:Add(self, self.OnAbilityEnd)
end

function BTTask_Born:OnAbilityEnd(Result)
    log.error('qqqqqqqqqqqqqqqqqqq', Result)
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