// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
#include "AttributeSet.h"
#include "AbilitySystemComponent.h"
#include "IkunAttrSet.generated.h"

#define ATTRIBUTE_ACCESSORS(ClassName, PropertyName) \
GAMEPLAYATTRIBUTE_PROPERTY_GETTER(ClassName, PropertyName) \
GAMEPLAYATTRIBUTE_VALUE_GETTER(PropertyName) \
GAMEPLAYATTRIBUTE_VALUE_SETTER(PropertyName) \
GAMEPLAYATTRIBUTE_VALUE_INITTER(PropertyName)

/**
 * @class 
 */
UCLASS()
class IKUN_API UIkunAttrSet : public UAttributeSet {
	GENERATED_BODY()
public:
	UIkunAttrSet();
	virtual void PreAttributeChange(const FGameplayAttribute& Attribute, float& NewValue) override;
	virtual void PostGameplayEffectExecute(const FGameplayEffectModCallbackData& Data) override;
	virtual void GetLifetimeReplicatedProps(TArray<FLifetimeProperty>& OutLifetimeProps) const override;
protected:
	void AdjustAttributeForMaxChange(FGameplayAttributeData& AffectedAttribute, const FGameplayAttributeData& MaxAttribute,
		float NewMaxValue, const FGameplayAttribute& AffectedAttributeProperty);

public:
	UPROPERTY(BlueprintReadOnly, Category = Health , ReplicatedUsing = OnRep_Health) 
	FGameplayAttributeData Health;
	ATTRIBUTE_ACCESSORS(UIkunAttrSet, Health)

	UPROPERTY(BlueprintReadOnly, Category = Health , ReplicatedUsing = OnRep_MaxHealth) 
	FGameplayAttributeData MaxHealth;
	ATTRIBUTE_ACCESSORS(UIkunAttrSet, MaxHealth)

	UPROPERTY(BlueprintReadOnly, Category = Attack , ReplicatedUsing = OnRep_AttackPower) 
	FGameplayAttributeData AttackPower;
	ATTRIBUTE_ACCESSORS(UIkunAttrSet, AttackPower)
	
	UPROPERTY(BlueprintReadOnly, Category = Move , ReplicatedUsing = OnRep_Speed) 
	FGameplayAttributeData Speed;
	ATTRIBUTE_ACCESSORS(UIkunAttrSet, Speed)

	UFUNCTION(BlueprintCallable)
	static FGameplayAttribute GetAttribute(FName Name);

protected:
	UFUNCTION()
	virtual void OnRep_Health(const FGameplayAttributeData& OldValue);
	UFUNCTION()
	virtual void OnRep_MaxHealth(const FGameplayAttributeData& OldValue);
	UFUNCTION()
	virtual void OnRep_AttackPower(const FGameplayAttributeData& OldValue);
	UFUNCTION()
	virtual void OnRep_Speed(const FGameplayAttributeData& OldValue);
};
