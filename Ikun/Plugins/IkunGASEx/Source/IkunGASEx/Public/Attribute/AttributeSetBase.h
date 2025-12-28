#pragma once

#include "CoreMinimal.h"
#include "AttributeSet.h"
#include "GameplayEffectExtension.h"
#include "AttributeSetBase.generated.h"

UCLASS()
class IKUNGASEX_API UAttributeSetBase : public UAttributeSet {
	GENERATED_BODY()
public:
	virtual void PreAttributeChange(const FGameplayAttribute& Attribute, float& NewValue) override;
	virtual void PostAttributeChange(const FGameplayAttribute& Attribute, float OldValue, float NewValue) override;
	virtual bool PreGameplayEffectExecute(struct FGameplayEffectModCallbackData& Data) override;
	virtual void PostGameplayEffectExecute(const struct FGameplayEffectModCallbackData& Data) override;

	UFUNCTION(BlueprintCallable)
	static FGameplayAttribute GetAttribute(FName Name);
	UFUNCTION(BlueprintCallable)
	float GetAttrValueByName(FName Name);
	
	UFUNCTION(BlueprintImplementableEvent)
	void OnPreAttributeChange(const FGameplayAttribute& Attribute, float& NewValue);
	UFUNCTION(BlueprintImplementableEvent)
	void OnPostAttributeChange(const FGameplayAttribute& Attribute, float OldValue, float NewValue);
	UFUNCTION(BlueprintImplementableEvent)
	bool OnPreGameplayEffectExecute(const struct FGameplayEffectSpec& EffectSpec, struct FGameplayModifierEvaluatedData& EvaluatedData, class UAbilitySystemComponent* Target);
	UFUNCTION(BlueprintImplementableEvent)
	void OnPostGameplayEffectExecute(const struct FGameplayEffectSpec& EffectSpec, struct FGameplayModifierEvaluatedData& EvaluatedData, class UAbilitySystemComponent* Target);
};