// Fill out your copyright notice in the Description page of Project Settings.

#include "GAS/IkunAttrSet.h"

#include "GameplayEffectExtension.h"
#include "GAS/IkunASC.h"
#include "Net/UnrealNetwork.h"

UIkunAttrSet::UIkunAttrSet(): 
	Health(100.f), MaxHealth(100.f),
	AttackPower(30.f), Stamina(100.f), MaxStamina(100.f),
	Mana(100.f), MaxMana(100.f), MagicPower(30.f),
	HealthRegen(1.f), ManaRegen(1.f), StaminaRegen(1.f),
	PhysicalDefense(10.f), MagicalDefense(10.f),
	Accuracy(100.f), Evasion(0.f), CriticalChance(0.f), CriticalResist(0.f),
	MoveSpeed(100.f) {
	
}

void UIkunAttrSet::PreAttributeChange(const FGameplayAttribute& Attribute, float& NewValue) {
	Super::PreAttributeChange(Attribute, NewValue);

	// 当调整最大生命值的时候要改变当前生命值
	if (Attribute == GetMaxHealthAttribute()) {
		AdjustAttributeForMaxChange(this->Health, MaxHealth, NewValue, GetHealthAttribute());
	}
}

void UIkunAttrSet::PostGameplayEffectExecute(const FGameplayEffectModCallbackData& Data) {
	Super::PostGameplayEffectExecute(Data);

	// 调整当前声明值的时候让其不要超过最大生命值也不要为负
	if (Data.EvaluatedData.Attribute == GetHealthAttribute()) {
		SetHealth(FMath::Clamp(GetHealth(), 0.0f, GetMaxHealth()));
	}
}

void UIkunAttrSet::GetLifetimeReplicatedProps(TArray<FLifetimeProperty>& OutLifetimeProps) const {
	Super::GetLifetimeReplicatedProps(OutLifetimeProps);

	DOREPLIFETIME(UIkunAttrSet, Health)
	DOREPLIFETIME(UIkunAttrSet, MaxHealth)
	DOREPLIFETIME(UIkunAttrSet, AttackPower)
	DOREPLIFETIME(UIkunAttrSet, Stamina)
	DOREPLIFETIME(UIkunAttrSet, MaxStamina)
	DOREPLIFETIME(UIkunAttrSet, Mana)
	DOREPLIFETIME(UIkunAttrSet, MaxMana)
	DOREPLIFETIME(UIkunAttrSet, MagicPower)
	DOREPLIFETIME(UIkunAttrSet, HealthRegen)
	DOREPLIFETIME(UIkunAttrSet, ManaRegen)
	DOREPLIFETIME(UIkunAttrSet, StaminaRegen)
	DOREPLIFETIME(UIkunAttrSet, PhysicalDefense)
	DOREPLIFETIME(UIkunAttrSet, MagicalDefense)
	DOREPLIFETIME(UIkunAttrSet, Accuracy)
	DOREPLIFETIME(UIkunAttrSet, Evasion)
	DOREPLIFETIME(UIkunAttrSet, CriticalChance)
	DOREPLIFETIME(UIkunAttrSet, CriticalResist)
	DOREPLIFETIME(UIkunAttrSet, MoveSpeed)
}

void UIkunAttrSet::AdjustAttributeForMaxChange(FGameplayAttributeData& AffectedAttribute,
	const FGameplayAttributeData& MaxAttribute, float NewMaxValue,
	const FGameplayAttribute& AffectedAttributeProperty) {
	UIkunASC* asc = Cast<UIkunASC>(GetOwningAbilitySystemComponent());
	const float curMaxValue = MaxAttribute.GetCurrentValue();
	if (!FMath::IsNearlyEqual(curMaxValue, NewMaxValue) && asc) {
		const float curValue = AffectedAttribute.GetCurrentValue();
		float newDelta = (curMaxValue > 0.0f) ? (curValue * NewMaxValue / curMaxValue) - curValue : NewMaxValue;
		asc->ApplyModToAttributeUnsafe(AffectedAttributeProperty, EGameplayModOp::Additive, newDelta);
	}
}

FGameplayAttribute UIkunAttrSet::GetAttribute(FName Name) {
	FProperty* Prop = FindFieldChecked<FProperty>(StaticClass(), Name);
	return Prop;
}

float UIkunAttrSet::GetAttrValueByName(FName Name) {
	FProperty* Prop = FindFieldChecked<FProperty>(StaticClass(), Name);
	FGameplayAttribute Attr = FGameplayAttribute(Prop);
	return Attr.GetNumericValueChecked(this);
}

void UIkunAttrSet::OnRep_Health(FGameplayAttributeData& OldValue) {
	GAMEPLAYATTRIBUTE_REPNOTIFY(UIkunAttrSet, Health, OldValue)
}

void UIkunAttrSet::OnRep_MaxHealth(FGameplayAttributeData& OldValue) {
	GAMEPLAYATTRIBUTE_REPNOTIFY(UIkunAttrSet, MaxHealth, OldValue)
}

void UIkunAttrSet::OnRep_AttackPower(FGameplayAttributeData& OldValue) {
	GAMEPLAYATTRIBUTE_REPNOTIFY(UIkunAttrSet, AttackPower, OldValue)
}

void UIkunAttrSet::OnRep_Stamina(FGameplayAttributeData& OldValue) {
	GAMEPLAYATTRIBUTE_REPNOTIFY(UIkunAttrSet, Stamina, OldValue)
}

void UIkunAttrSet::OnRep_MaxStamina(FGameplayAttributeData& OldValue) {
	GAMEPLAYATTRIBUTE_REPNOTIFY(UIkunAttrSet, MaxStamina, OldValue)
}

void UIkunAttrSet::OnRep_Mana(FGameplayAttributeData& OldValue) {
	GAMEPLAYATTRIBUTE_REPNOTIFY(UIkunAttrSet, Mana, OldValue)
}

void UIkunAttrSet::OnRep_MaxMana(FGameplayAttributeData& OldValue) {
	GAMEPLAYATTRIBUTE_REPNOTIFY(UIkunAttrSet, MaxMana, OldValue)
}

void UIkunAttrSet::OnRep_MagicPower(FGameplayAttributeData& OldValue) {
	GAMEPLAYATTRIBUTE_REPNOTIFY(UIkunAttrSet, MagicPower, OldValue)
}

void UIkunAttrSet::OnRep_HealthRegen(FGameplayAttributeData& OldValue) {
	GAMEPLAYATTRIBUTE_REPNOTIFY(UIkunAttrSet, HealthRegen, OldValue)
}

void UIkunAttrSet::OnRep_ManaRegen(FGameplayAttributeData& OldValue) {
	GAMEPLAYATTRIBUTE_REPNOTIFY(UIkunAttrSet, ManaRegen, OldValue)
}

void UIkunAttrSet::OnRep_StaminaRegen(FGameplayAttributeData& OldValue) {
	GAMEPLAYATTRIBUTE_REPNOTIFY(UIkunAttrSet, StaminaRegen, OldValue)
}

void UIkunAttrSet::OnRep_PhysicalDefense(FGameplayAttributeData& OldValue) {
	GAMEPLAYATTRIBUTE_REPNOTIFY(UIkunAttrSet, PhysicalDefense, OldValue)
}

void UIkunAttrSet::OnRep_MagicalDefense(FGameplayAttributeData& OldValue) {
	GAMEPLAYATTRIBUTE_REPNOTIFY(UIkunAttrSet, MagicalDefense, OldValue)
}

void UIkunAttrSet::OnRep_Accuracy(FGameplayAttributeData& OldValue) {
	GAMEPLAYATTRIBUTE_REPNOTIFY(UIkunAttrSet, Accuracy, OldValue)
}

void UIkunAttrSet::OnRep_Evasion(FGameplayAttributeData& OldValue) {
	GAMEPLAYATTRIBUTE_REPNOTIFY(UIkunAttrSet, Evasion, OldValue)
}

void UIkunAttrSet::OnRep_CriticalChance(FGameplayAttributeData& OldValue) {
	GAMEPLAYATTRIBUTE_REPNOTIFY(UIkunAttrSet, CriticalChance, OldValue)
}

void UIkunAttrSet::OnRep_CriticalResist(FGameplayAttributeData& OldValue) {
	GAMEPLAYATTRIBUTE_REPNOTIFY(UIkunAttrSet, CriticalResist, OldValue)
}

void UIkunAttrSet::OnRep_MoveSpeed(FGameplayAttributeData& OldValue) {
	GAMEPLAYATTRIBUTE_REPNOTIFY(UIkunAttrSet, MoveSpeed, OldValue)
}