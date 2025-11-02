// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
#include "AbilitySystemComponent.h"
#include "IkunASC.generated.h"

DECLARE_DYNAMIC_MULTICAST_DELEGATE_TwoParams(FOnTagUpdated, const FGameplayTag&, Tag, bool, TagExists);

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

	virtual void OnTagUpdated(const FGameplayTag& Tag, bool TagExists) override;

	UPROPERTY(BlueprintAssignable)
	FOnTagUpdated OnTagChanged;

	/***
	 * @desc 此流程中在GameplayEventTriggeredAbilities中添加的Spec在ClearAbility时被CheckForClearedAbilities清除, 故结果正常
	 */
	UFUNCTION(BlueprintCallable)
	FGameplayAbilitySpecHandle GiveAbilityWithDynTriggerTag(TSubclassOf<UGameplayAbility> AbilityClass, FGameplayTag TriggerTag, int32 Level = 0, int32 InputID = -1);

	UFUNCTION(BlueprintCallable)
	void TryActiveAbilityWithPaylod(FGameplayAbilitySpecHandle InHandle, const FGameplayEventData& Payload);
};
