#include "AbilitySystemComponent/AbilitySystemBaseComponent.h"

UAbilitySystemBaseComponent::UAbilitySystemBaseComponent(const FObjectInitializer& ObjectInitializer): Super(ObjectInitializer) {
	PrimaryComponentTick.bCanEverTick = true;

	for (auto& set : this->InitAttributeSets) {
		this->K2_InitStats(set, nullptr);
	}
}

void UAbilitySystemBaseComponent::BeginPlay() {
	Super::BeginPlay();
}

void UAbilitySystemBaseComponent::TickComponent(float DeltaTime, ELevelTick TickType, FActorComponentTickFunction* ThisTickFunction) {
	Super::TickComponent(DeltaTime, TickType, ThisTickFunction);
}

void UAbilitySystemBaseComponent::TryActiveAbilityWithPaylod(FGameplayAbilitySpecHandle InHandle, const FGameplayEventData& Payload) {
	this->TriggerAbilityFromGameplayEvent(InHandle, this->AbilityActorInfo.Get(), FGameplayTag(), &Payload, *this);
}

