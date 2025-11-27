#include "Attribute/AttributeSetBase.h"

void UAttributeSetBase::PreAttributeChange(const FGameplayAttribute& Attribute, float& NewValue) {
	Super::PreAttributeChange(Attribute, NewValue);
	this->OnPreAttributeChange(Attribute, NewValue);
}

void UAttributeSetBase::PostAttributeChange(const FGameplayAttribute& Attribute, float OldValue, float NewValue) {
	Super::PostAttributeChange(Attribute, OldValue, NewValue);
	this->OnPostAttributeChange(Attribute, OldValue, NewValue);
}

bool UAttributeSetBase::PreGameplayEffectExecute(struct FGameplayEffectModCallbackData& Data) {
	Super::PreGameplayEffectExecute(Data);
	return this->OnPreGameplayEffectExecute(Data.EffectSpec, Data.EvaluatedData, &Data.Target);
}

void UAttributeSetBase::PostGameplayEffectExecute(const struct FGameplayEffectModCallbackData& Data) {
	Super::PostGameplayEffectExecute(Data);
	this->OnPostGameplayEffectExecute(Data.EffectSpec, Data.EvaluatedData, &Data.Target);
}