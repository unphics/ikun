#include "AbilitySystemComponent/AbilitySystemBaseComponent.h"

UAbilitySystemBaseComponent::UAbilitySystemBaseComponent(const FObjectInitializer& ObjectInitializer): Super(ObjectInitializer) {
	PrimaryComponentTick.bCanEverTick = true;
}

void UAbilitySystemBaseComponent::BeginPlay() {
	Super::BeginPlay();
}

void UAbilitySystemBaseComponent::TickComponent(float DeltaTime, ELevelTick TickType, FActorComponentTickFunction* ThisTickFunction) {
	Super::TickComponent(DeltaTime, TickType, ThisTickFunction);
}

bool UAbilitySystemBaseComponent::K2_TryActiveAbilityWithPaylod(FGameplayAbilitySpecHandle InHandle, const FGameplayEventData& Payload) {
	return this->TriggerAbilityFromGameplayEvent(InHandle, this->AbilityActorInfo.Get(), FGameplayTag(), &Payload, *this);
}

