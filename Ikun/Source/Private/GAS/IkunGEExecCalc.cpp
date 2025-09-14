// Fill out your copyright notice in the Description page of Project Settings.


#include "GAS/IkunGEExecCalc.h"
#include "GameplayEffect.h"
#include "GAS/IkunASC.h"
#include "GameplayEffectAggregator.h"
#include "GAS/IkunAttrSet.h"


void UIkunEffectCalc::InitEffectCalcData(const FGameplayEffectCustomExecutionParameters& ExecutionParams) {
	this->InExecParams = ExecutionParams;
	this->SourceAvatar = ExecutionParams.GetSourceAbilitySystemComponent() ? ExecutionParams.GetSourceAbilitySystemComponent()->GetAvatarActor() : nullptr;
	this->TargetAvatar = ExecutionParams.GetTargetAbilitySystemComponent() ? ExecutionParams.GetTargetAbilitySystemComponent()->GetAvatarActor() : nullptr;
	this->Spec = ExecutionParams.GetOwningSpec();
	this->EvaluateParameters = FAggregatorEvaluateParameters();
	this->EvaluateParameters.SourceTags = Spec.CapturedSourceTags.GetAggregatedTags();
	this->EvaluateParameters.TargetTags = Spec.CapturedTargetTags.GetAggregatedTags();
}
FGameplayEffectCustomExecutionOutput UIkunEffectCalc::CalcEffectData(const FGameplayEffectCustomExecutionParameters& ExecutionParams) {
	this->InitEffectCalcData(ExecutionParams);
	this->OnCalcEffectData();
	return this->OutExecParams;
}
float UIkunEffectCalc::ReadAttrValue(FName Name, bool bSource) {
	float AttrValue = 0.f;
	FProperty* Prop = FindFieldChecked<FProperty>(UIkunAttrSet::StaticClass(), Name);
	FGameplayEffectAttributeCaptureDefinition CapDef(Prop, bSource ? EGameplayEffectAttributeCaptureSource::Source: EGameplayEffectAttributeCaptureSource::Target, false);
	this->InExecParams.AttemptCalculateCapturedAttributeMagnitude(CapDef, EvaluateParameters, AttrValue);
	return AttrValue;
}
void UIkunEffectCalc::ModiAttrValue(FName Name, float Value, TEnumAsByte<EGameplayModOp::Type> ModOp) {
	FProperty* Prop = FindFieldChecked<FProperty>(UIkunAttrSet::StaticClass(), Name);
	const FGameplayModifierEvaluatedData EvaluatedData(Prop, ModOp, Value);
	OutExecParams.AddOutputModifier(EvaluatedData);
}


UIkunGEExecCalc::UIkunGEExecCalc(const FObjectInitializer& ObjectInitializer) : Super(ObjectInitializer) {}

void UIkunGEExecCalc::Execute(const FGameplayEffectCustomExecutionParameters& ExecutionParams, FGameplayEffectCustomExecutionOutput& OutExecutionOutput) const {
	//const UAbilitySystemComponent* SourceASC = ExecutionParams.GetSourceAbilitySystemComponent();
	//const UAbilitySystemComponent* TargetASC = ExecutionParams.GetTargetAbilitySystemComponent();

	//const AActor* SourceAvatar = SourceASC ? SourceASC->GetAvatarActor() : nullptr;
	//const AActor* TargetAvatar = TargetASC ? TargetASC->GetAvatarActor() : nullptr;

	//const FGameplayEffectSpec& Spec = ExecutionParams.GetOwningSpec();

	//const FGameplayTagContainer* SourceTags = Spec.CapturedSourceTags.GetAggregatedTags();
	//const FGameplayTagContainer* TargetTags = Spec.CapturedTargetTags.GetAggregatedTags();
	//FAggregatorEvaluateParameters EvaluateParameters;
	//EvaluateParameters.SourceTags = SourceTags;
	//EvaluateParameters.TargetTags = TargetTags;

	//float Health = 0.f;
	//FName Name;
	//FProperty* Prop = FindFieldChecked<FProperty>(UIkunAttrSet::StaticClass(), Name);
	//FGameplayEffectAttributeCaptureDefinition CapDef(Prop, EGameplayEffectAttributeCaptureSource::Source, false);
	//ExecutionParams.AttemptCalculateCapturedAttributeMagnitude(CapDef, EvaluateParameters, Health);

	//Health -= 3;
	//const FGameplayModifierEvaluatedData EvaluatedData(Prop, EGameplayModOp::Additive, Health);
	//OutExecutionOutput.AddOutputModifier(EvaluatedData);
}