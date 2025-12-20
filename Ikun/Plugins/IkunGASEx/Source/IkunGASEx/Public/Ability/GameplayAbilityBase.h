#pragma once

#include "CoreMinimal.h"
#include "Abilities/GameplayAbility.h"
#include "GameplayAbilityBase.generated.h"

DECLARE_DYNAMIC_MULTICAST_DELEGATE_OneParam(FOnAbilityEndDelegate, bool, bWasCancelled);

class UGameplayTask;
class UAbilityAsync;

UCLASS()
class IKUNGASEX_API UGameplayAbilityBase : public UGameplayAbility {
	GENERATED_BODY()
public:
	UGameplayAbilityBase(const FObjectInitializer& ObjectInitializer);
	virtual void EndAbility(const FGameplayAbilitySpecHandle Handle, const FGameplayAbilityActorInfo* ActorInfo, const FGameplayAbilityActivationInfo ActivationInfo, bool bReplicateEndAbility, bool bWasCancelled);
	UPROPERTY(BlueprintAssignable)
	FOnAbilityEndDelegate OnAbilityEndEvent;
	UPROPERTY(BlueprintReadWrite)
	TArray<UGameplayTask*> RefTasks;
	UPROPERTY(BlueprintReadWrite)
	TArray<UAbilityAsync*> RefAsyncs;
};
