// Fill out your copyright notice in the Description page of Project Settings.

#include "GAS/ASC/IkunASC.h"

#include "AbilitySystemGlobals.h"

#include "GAS/GA/IkunGABase.h"

UIkunASC::UIkunASC() {
	this->PrimaryComponentTick.bCanEverTick = true;
	
}

void UIkunASC::BeginPlay() {
	Super::BeginPlay();
}

void UIkunASC::TickComponent(float DeltaTime, ELevelTick TickType, FActorComponentTickFunction* ThisTickFunction) {
	Super::TickComponent(DeltaTime, TickType, ThisTickFunction);
}

UIkunASC* UIkunASC::GetAscFromActor(const AActor* Actor, bool bLookForComp) {
	return Cast<UIkunASC>(UAbilitySystemGlobals::GetAbilitySystemComponentFromActor(Actor, bLookForComp));
}

void UIkunASC::GetActivateAbilitiesWithTag(const FGameplayTagContainer& GameplayTagContainer,
	TArray<UIkunGABase*>& ActiveAbilities) {
	TArray<FGameplayAbilitySpec*> AbilitiesToActivate;
	GetActivatableGameplayAbilitySpecsByAllMatchingTags(GameplayTagContainer, AbilitiesToActivate, false);

	// Iterate the list of all ability specs
	for (FGameplayAbilitySpec* Spec : AbilitiesToActivate) {
		// Iterate all instances on this ability spec
		TArray<UGameplayAbility*> AbilityInstances = Spec->GetAbilityInstances();
		for (UGameplayAbility* ActiveAbility : AbilityInstances) {
			ActiveAbilities.Add(Cast<UIkunGABase>(ActiveAbility));
		}
	}
}
