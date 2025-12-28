#pragma once

#include "CoreMinimal.h"
#include "Abilities/GameplayAbilityTargetActor.h"
#include "TargetActorBase.generated.h"

UCLASS()
class IKUNGASEX_API ATargetActorBase : public AGameplayAbilityTargetActor {
	GENERATED_BODY()
public:
	ATargetActorBase();
public:
	UFUNCTION(BlueprintCallable)
	void K2_ConfirmTargeting();
	virtual void StartTargeting(UGameplayAbility* Ability) override;
	virtual void ConfirmTargetingAndContinue() override;
	UFUNCTION(BlueprintImplementableEvent)
	void OnStartTargeting(UGameplayAbility* Ability);
	UFUNCTION(BlueprintImplementableEvent)
	void OnConfirmTargetingAndContinue();
};