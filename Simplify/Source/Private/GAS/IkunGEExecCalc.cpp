// Fill out your copyright notice in the Description page of Project Settings.


#include "GAS/IkunGEExecCalc.h"
#include "GameplayEffect.h"
#include "GAS/IkunASC.h"
#include "GameplayEffectAggregator.h"
#include "GAS/IkunAttrSet.h"

UIkunGEExecCalc::UIkunGEExecCalc(const FObjectInitializer& ObjectInitializer) : Super(ObjectInitializer) {
	
}

AActor* UIkunGEExecCalc::GetExecSourceAvatar(const FGameplayEffectCustomExecutionParameters& ExecutionParams) {
	const UAbilitySystemComponent* SourceASC = ExecutionParams.GetSourceAbilitySystemComponent();
	return SourceASC ? SourceASC->GetAvatarActor() : nullptr;
}
AActor* UIkunGEExecCalc::GetExecTargetAvatar(const FGameplayEffectCustomExecutionParameters& ExecutionParams) {
	const UAbilitySystemComponent* SourceASC = ExecutionParams.GetSourceAbilitySystemComponent();
	return SourceASC ? SourceASC->GetAvatarActor() : nullptr;
}
const FGameplayEffectSpec& UIkunGEExecCalc::GetExecGESpec(const FGameplayEffectCustomExecutionParameters& ExecutionParams) {
	return ExecutionParams.GetOwningSpec();
}

FAggrEval UIkunGEExecCalc::MakeExecAggrEval(const FGameplayEffectSpec& Spec) {
	const FGameplayTagContainer* SourceTags = Spec.CapturedSourceTags.GetAggregatedTags();
	const FGameplayTagContainer* TargetTags = Spec.CapturedTargetTags.GetAggregatedTags();
	FAggrEval AggrEval;
	AggrEval.AggrEvalParam.SourceTags = SourceTags;
	AggrEval.AggrEvalParam.TargetTags = TargetTags;
	return AggrEval;
}

float UIkunGEExecCalc::GetExecAttrVal(const FGameplayEffectCustomExecutionParameters& ExecutionParams, FGameplayAttribute Prop, const FAggrEval& EvaluateParameters) {
	float AttrVal;
	FGameplayEffectAttributeCaptureDefinition CapDef(Prop, EGameplayEffectAttributeCaptureSource::Source, false);
	ExecutionParams.AttemptCalculateCapturedAttributeMagnitude(CapDef, EvaluateParameters.AggrEvalParam, AttrVal);
	return AttrVal;
}

FGameplayEffectCustomExecutionOutput UIkunGEExecCalc::ModiExecAttrVal(FGameplayEffectCustomExecutionOutput OutExecutionOutput, FGameplayAttribute Prop, float AttrVal) {
	const FGameplayModifierEvaluatedData EvaluatedData(Prop, EGameplayModOp::Additive, AttrVal);
	OutExecutionOutput.AddOutputModifier(EvaluatedData);
	return OutExecutionOutput;
}


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

void UIkunGEExecCalc::Test(const FGameplayEffectCustomExecutionParameters& ExecutionParams, FGameplayEffectCustomExecutionOutput& OutExecutionOutput) const {
	const UAbilitySystemComponent* SourceASC = ExecutionParams.GetSourceAbilitySystemComponent();
	const UAbilitySystemComponent* TargetASC = ExecutionParams.GetTargetAbilitySystemComponent();

	const AActor* SourceAvatar = SourceASC ? SourceASC->GetAvatarActor() : nullptr;
	const AActor* TargetAvatar = TargetASC ? TargetASC->GetAvatarActor() : nullptr;

	const FGameplayEffectSpec& Spec = ExecutionParams.GetOwningSpec();

	const FGameplayTagContainer* SourceTags = Spec.CapturedSourceTags.GetAggregatedTags();
	const FGameplayTagContainer* TargetTags = Spec.CapturedTargetTags.GetAggregatedTags();
	FAggregatorEvaluateParameters EvaluateParameters;
	EvaluateParameters.SourceTags = SourceTags;
	EvaluateParameters.TargetTags = TargetTags;

	float Health = 0.f;
	FName Name;
	FProperty* Prop = FindFieldChecked<FProperty>(UIkunAttrSet::StaticClass(), Name);
	FGameplayEffectAttributeCaptureDefinition CapDef(Prop, EGameplayEffectAttributeCaptureSource::Source, false);
	ExecutionParams.AttemptCalculateCapturedAttributeMagnitude(CapDef, EvaluateParameters, Health);

	Health -= 3;
	const FGameplayModifierEvaluatedData EvaluatedData(Prop, EGameplayModOp::Additive, Health);
	OutExecutionOutput.AddOutputModifier(EvaluatedData);
}