// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
#include "AbilitySystemGlobals.h"
#include "IkunAbilitySystemGlobals.generated.h"

/**
 * 
 */
UCLASS()
class IKUN_API UIkunAbilitySystemGlobals : public UAbilitySystemGlobals {
	GENERATED_BODY()
public:
	virtual FGameplayEffectContext* AllocGameplayEffectContext() const override;
};
