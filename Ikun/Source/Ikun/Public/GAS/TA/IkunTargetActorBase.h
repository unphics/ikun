// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
#include "Abilities/GameplayAbilityTargetActor.h"
#include "IkunTargetActorBase.generated.h"

/**
 * 
 */
UCLASS()
class IKUN_API AIkunTargetActorBase : public AGameplayAbilityTargetActor
{
	GENERATED_BODY()
public:
	AIkunTargetActorBase();

	UFUNCTION(BlueprintCallable)
	virtual void StartTargeting(UGameplayAbility* Ability) override;
	UFUNCTION(BlueprintCallable)
	virtual void ConfirmTargetingAndContinue() override;

	//UFUNCTION(BlueprintCallable)
	//void K2_StartTargeting(UGameplayAbility* Ability);
	//UFUNCTION(BlueprintCallable)
	//void K2_ConfirmTargetingAndContinue();
};
