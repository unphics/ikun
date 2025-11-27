#pragma once

#include "CoreMinimal.h"
#include "Abilities/Tasks/AbilityTask_WaitTargetData.h"
#include "AbilityTask_WaitTargetDataBase.generated.h"

UCLASS()
class IKUNGASEX_API UAbilityTask_WaitTargetDataBase : public UAbilityTask_WaitTargetData {
	GENERATED_BODY()
public:
	UFUNCTION(BlueprintCallable, meta = (HidePin = "OwningAbility", DefaultToSelf = "OwningAbility", BlueprintInternalUseOnly = "true", HideSpawnParms = "Instigator"), Category = "Ability|Tasks")
	static UAbilityTask_WaitTargetDataBase* WaitTargetDataUseCustomActor(UGameplayAbility* OwningAbility, FName TaskInstanceName, TEnumAsByte<EGameplayTargetingConfirmation::Type> ConfirmationType, AGameplayAbilityTargetActor* InTargetActor);
	virtual void OnDestroy(bool AbilityEnded) override;
};
