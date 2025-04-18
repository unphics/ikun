// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
#include "Abilities/GameplayAbilityTargetTypes.h"
#include "UObject/Object.h"
#include "ApplyDataContainer.generated.h"

/**
 * 
 */
UCLASS(BlueprintType, Blueprintable)
class IKUN_API UApplyDataContainer : public UObject {
	GENERATED_BODY()
public:
	UApplyDataContainer() {}

	UPROPERTY(EditAnywhere, BlueprintReadWrite)
	AActor* Instigator;

	UPROPERTY(EditAnywhere, BlueprintReadWrite)
	UGameplayAbility* Ability;

	UPROPERTY(EditAnywhere, BlueprintReadWrite)
	TArray<UObject*> ApplyActors;

	UPROPERTY(EditAnywhere, BlueprintReadWrite)
	FGameplayAbilityTargetDataHandle TargetDataHandle;

	UPROPERTY(EditAnywhere, BlueprintReadWrite)
	TArray<TSubclassOf<UGameplayEffect>> GameplayEffectClasses;

	UPROPERTY(EditAnywhere, BlueprintReadWrite)
	TArray<FGameplayEffectSpecHandle> GameplayEffectSpecs;
};
