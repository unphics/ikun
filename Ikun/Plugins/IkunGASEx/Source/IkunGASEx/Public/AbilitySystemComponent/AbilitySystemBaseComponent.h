#pragma once

#include "CoreMinimal.h"
#include "AbilitySystemComponent.h"
#include "AbilitySystemBaseComponent.generated.h"

UCLASS(ClassGroup=(Custom), meta=(BlueprintSpawnableComponent))
class IKUNGASEX_API UAbilitySystemBaseComponent : public UAbilitySystemComponent {
	GENERATED_BODY()
public:
	UAbilitySystemBaseComponent(const FObjectInitializer& ObjectInitializer);
	virtual void BeginPlay() override;
	virtual void TickComponent(float DeltaTime, ELevelTick TickType, FActorComponentTickFunction* ThisTickFunction) override;
public:
	UFUNCTION(BlueprintCallable)
	bool K2_TryActiveAbilityWithPaylod(FGameplayAbilitySpecHandle InHandle, const FGameplayEventData& Payload);
public:
};