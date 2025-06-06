// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
#include "AbilitySystemComponent.h"
#include "IkunASC.generated.h"

class UIkunGABase;
/**
 * 
 */
UCLASS(ClassGroup=(Custom), meta=(BlueprintSpawnableComponent))
class IKUN_API UIkunASC : public UAbilitySystemComponent {
	GENERATED_BODY()
public:
	UIkunASC();
	virtual void BeginPlay() override;
	virtual void TickComponent(float DeltaTime, ELevelTick TickType, FActorComponentTickFunction* ThisTickFunction) override;
	static UIkunASC* GetAscFromActor(const AActor* Actor, bool bLookForComp = false);
	UFUNCTION(BlueprintCallable)
	void GetActivateAbilitiesWithTag(const FGameplayTagContainer& GameplayTagContainer, TArray<UIkunGABase*>& ActiveAbilities);
	UFUNCTION(BlueprintCallable)
	bool HasGameplayTag(FGameplayTag TagToCheck) const;
};
