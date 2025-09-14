// Fill out your copyright notice in the Description page of Project Settings.


#include "GAS/IkunAbilitySystemGlobals.h"

#include "GAS/IkunAbilityTypes.h"

FGameplayEffectContext* UIkunAbilitySystemGlobals::AllocGameplayEffectContext() const {
	return new FIkunGameplayEffectContext();
}
