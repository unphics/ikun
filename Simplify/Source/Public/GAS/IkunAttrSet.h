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
	UPROPERTY(BlueprintReadOnly, Category = Health, ReplicatedUsing = OnRep_Health) 
	FGameplayAttributeData Health; // 生命值
	ATTRIBUTE_ACCESSORS(UIkunAttrSet, Health)

	UPROPERTY(BlueprintReadOnly, Category = Health, ReplicatedUsing = OnRep_MaxHealth) 
	FGameplayAttributeData MaxHealth; // 最大生命值
	ATTRIBUTE_ACCESSORS(UIkunAttrSet, MaxHealth)

	UPROPERTY(BlueprintReadOnly, Category = Attack, ReplicatedUsing = OnRep_AttackPower) 
	FGameplayAttributeData AttackPower; // 攻击力
	ATTRIBUTE_ACCESSORS(UIkunAttrSet, AttackPower)

	UPROPERTY(BlueprintReadOnly, Category = Attack, ReplicatedUsing = OnRep_Stamina)
	FGameplayAttributeData Stamina; // 耐力值
	ATTRIBUTE_ACCESSORS(UIkunAttrSet, Stamina)

	UPROPERTY(BlueprintReadOnly, Category = Attack, ReplicatedUsing = OnRep_MaxStamina)
	FGameplayAttributeData MaxStamina; // 最大耐力值
	ATTRIBUTE_ACCESSORS(UIkunAttrSet, MaxStamina)

	UPROPERTY(BlueprintReadOnly, Category = Mana, ReplicatedUsing = OnRep_Mana)
	FGameplayAttributeData Mana; // 魔法值
	ATTRIBUTE_ACCESSORS(UIkunAttrSet, Mana)

	UPROPERTY(BlueprintReadOnly, Category = Mana, ReplicatedUsing = OnRep_MaxMana)
	FGameplayAttributeData MaxMana; // 最大魔法值
	ATTRIBUTE_ACCESSORS(UIkunAttrSet, MaxMana)

	UPROPERTY(BlueprintReadOnly, Category = Mana, ReplicatedUsing = OnRep_MagicPower)
	FGameplayAttributeData MagicPower; // 魔法攻击力
	ATTRIBUTE_ACCESSORS(UIkunAttrSet, MagicPower)

	UPROPERTY(BlueprintReadOnly, Category = Regen, ReplicatedUsing = OnRep_HealthRegen)
	FGameplayAttributeData HealthRegen; // 生命回复
	ATTRIBUTE_ACCESSORS(UIkunAttrSet, HealthRegen)

	UPROPERTY(BlueprintReadOnly, Category = Regen, ReplicatedUsing = OnRep_ManaRegen)
	FGameplayAttributeData ManaRegen; // 魔法回复
	ATTRIBUTE_ACCESSORS(UIkunAttrSet, ManaRegen)

	UPROPERTY(BlueprintReadOnly, Category = Regen, ReplicatedUsing = OnRep_StaminaRegen)
	FGameplayAttributeData StaminaRegen; // 耐力回复
	ATTRIBUTE_ACCESSORS(UIkunAttrSet, StaminaRegen)

	UPROPERTY(BlueprintReadOnly, Category = Defense, ReplicatedUsing = OnRep_PhysicalDefense)
	FGameplayAttributeData PhysicalDefense; // 物理防御
	ATTRIBUTE_ACCESSORS(UIkunAttrSet, PhysicalDefense)

	UPROPERTY(BlueprintReadOnly, Category = Defense, ReplicatedUsing = OnRep_MagicalDefense)
	FGameplayAttributeData MagicalDefense; // 魔法防御
	ATTRIBUTE_ACCESSORS(UIkunAttrSet, MagicalDefense)

	UPROPERTY(BlueprintReadOnly, Category = Combat, ReplicatedUsing = OnRep_Accuracy)
	FGameplayAttributeData Accuracy; // 命中率
	ATTRIBUTE_ACCESSORS(UIkunAttrSet, Accuracy)

	UPROPERTY(BlueprintReadOnly, Category = Combat, ReplicatedUsing = OnRep_Evasion)
	FGameplayAttributeData Evasion; // 闪避率
	ATTRIBUTE_ACCESSORS(UIkunAttrSet, Evasion)

	UPROPERTY(BlueprintReadOnly, Category = Combat, ReplicatedUsing = OnRep_CriticalChance)
	FGameplayAttributeData CriticalChance; // 暴击率
	ATTRIBUTE_ACCESSORS(UIkunAttrSet, CriticalChance)

	UPROPERTY(BlueprintReadOnly, Category = Combat, ReplicatedUsing = OnRep_CriticalResist)
	FGameplayAttributeData CriticalResist; // 暴击抗性
	ATTRIBUTE_ACCESSORS(UIkunAttrSet, CriticalResist)
	
	UPROPERTY(BlueprintReadOnly, Category = Move , ReplicatedUsing = OnRep_MoveSpeed) 
	FGameplayAttributeData MoveSpeed; // 移动速度
	ATTRIBUTE_ACCESSORS(UIkunAttrSet, MoveSpeed)

	UFUNCTION(BlueprintCallable)
	static FGameplayAttribute GetAttribute(FName Name);

	UFUNCTION(BlueprintCallable)
	float GetAttrValueByName(FName Name);

protected:
	UFUNCTION()
	virtual void OnRep_Health(FGameplayAttributeData& OldValue);
	UFUNCTION()
	virtual void OnRep_MaxHealth(FGameplayAttributeData& OldValue);
	UFUNCTION()
	virtual void OnRep_AttackPower(FGameplayAttributeData& OldValue);
	UFUNCTION()
	virtual void OnRep_Stamina(FGameplayAttributeData& OldValue);
	UFUNCTION()
	virtual void OnRep_MaxStamina(FGameplayAttributeData& OldValue);
	UFUNCTION()
	virtual void OnRep_Mana(FGameplayAttributeData& OldValue);
	UFUNCTION()
	virtual void OnRep_MaxMana(FGameplayAttributeData& OldValue);
	UFUNCTION()
	virtual void OnRep_MagicPower(FGameplayAttributeData& OldValue);
	UFUNCTION()
	virtual void OnRep_HealthRegen(FGameplayAttributeData& OldValue);
	UFUNCTION()
	virtual void OnRep_ManaRegen(FGameplayAttributeData& OldValue);
	UFUNCTION()
	virtual void OnRep_StaminaRegen(FGameplayAttributeData& OldValue);
	UFUNCTION()
	virtual void OnRep_PhysicalDefense(FGameplayAttributeData& OldValue);
	UFUNCTION()
	virtual void OnRep_MagicalDefense(FGameplayAttributeData& OldValue);
	UFUNCTION()
	virtual void OnRep_Accuracy(FGameplayAttributeData& OldValue);
	UFUNCTION()
	virtual void OnRep_Evasion(FGameplayAttributeData& OldValue);
	UFUNCTION()
	virtual void OnRep_CriticalChance(FGameplayAttributeData& OldValue);
	UFUNCTION()
	virtual void OnRep_CriticalResist(FGameplayAttributeData& OldValue);
	UFUNCTION()
	virtual void OnRep_MoveSpeed(FGameplayAttributeData& OldValue);
};
