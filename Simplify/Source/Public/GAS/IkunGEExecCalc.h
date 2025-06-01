// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
#include "GameplayEffectExecutionCalculation.h"
#include "IkunGEExecCalc.generated.h"

/**
 * 
 */

USTRUCT(BlueprintType)
struct IKUN_API FAggrEval {
	GENERATED_BODY();
	FAggregatorEvaluateParameters AggrEvalParam;
};

UCLASS()
class IKUN_API UIkunGEExecCalc : public UGameplayEffectExecutionCalculation {
	GENERATED_BODY()
public:
	UIkunGEExecCalc(const FObjectInitializer& ObjectInitializer);
	void Execute(const FGameplayEffectCustomExecutionParameters& ExecutionParams, FGameplayEffectCustomExecutionOutput& OutExecutionOutput) const;



	UFUNCTION(BlueprintCallable)
	static AActor* GetExecSourceAvatar(const FGameplayEffectCustomExecutionParameters& ExecutionParams);

	UFUNCTION(BlueprintCallable)
	static AActor* GetExecTargetAvatar(const FGameplayEffectCustomExecutionParameters& ExecutionParams);

	UFUNCTION(BlueprintCallable)
	static const FGameplayEffectSpec& GetExecGESpec(const FGameplayEffectCustomExecutionParameters& ExecutionParams);

	UFUNCTION(BlueprintCallable)
	static FAggrEval MakeExecAggrEval(const FGameplayEffectSpec& Spec);

	UFUNCTION(BlueprintCallable)
	static float GetExecAttrVal(const FGameplayEffectCustomExecutionParameters& ExecutionParams, FGameplayAttribute Prop, const FAggrEval& EvaluateParameters);

	UFUNCTION(BlueprintCallable)
	static FGameplayEffectCustomExecutionOutput ModiExecAttrVal(FGameplayEffectCustomExecutionOutput OutExecutionOutput, FGameplayAttribute Prop, float AttrVal);

	UFUNCTION(BlueprintCallable)
	void Test(const FGameplayEffectCustomExecutionParameters& ExecutionParams, FGameplayEffectCustomExecutionOutput& OutExecutionOutput) const;
};
