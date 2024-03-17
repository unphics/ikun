// Fill out your copyright notice in the Description page of Project Settings.

#include "GAS/AttrSet/IkunAttrSet.h"

#include "GameplayEffectExtension.h"
#include "GAS/ASC/IkunASC.h"
#include "Net/UnrealNetwork.h"

UIkunAttrSet::UIkunAttrSet(): Health(100.f), MaxHealth(100.f), AttackPower(30.f) {
	
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
	DOREPLIFETIME(UIkunAttrSet, Speed)
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

void UIkunAttrSet::OnRep_Health(const FGameplayAttributeData& OldValue) {
	GAMEPLAYATTRIBUTE_REPNOTIFY(UIkunAttrSet, Health, OldValue)
}

void UIkunAttrSet::OnRep_MaxHealth(const FGameplayAttributeData& OldValue) {
	GAMEPLAYATTRIBUTE_REPNOTIFY(UIkunAttrSet, MaxHealth, OldValue)
}

void UIkunAttrSet::OnRep_AttackPower(const FGameplayAttributeData& OldValue) {
	GAMEPLAYATTRIBUTE_REPNOTIFY(UIkunAttrSet, AttackPower, OldValue)
}

void UIkunAttrSet::OnRep_Speed(const FGameplayAttributeData& OldValue) {
	GAMEPLAYATTRIBUTE_REPNOTIFY(UIkunAttrSet, Speed, OldValue)
}
