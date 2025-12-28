// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
#include "GameplayEffectExecutionCalculation.h"
#include "IkunGEExecCalc.generated.h"


UCLASS(BlueprintType, Blueprintable)
class IKUN_API UIkunEffectCalc : public UObject {
	GENERATED_BODY()
public:
	UFUNCTION(BlueprintCallable)
	void InitEffectCalcData(const FGameplayEffectCustomExecutionParameters& ExecutionParams);
	UFUNCTION(BlueprintCallable)
	virtual FGameplayEffectCustomExecutionOutput CalcEffectData(const FGameplayEffectCustomExecutionParameters& ExecutionParams);
	UFUNCTION(BlueprintCallable, BlueprintImplementableEvent)
	void OnCalcEffectData();
	UFUNCTION(BlueprintCallable)
	float ReadAttrValue(FName Name, bool bSource = false);
	UFUNCTION(BlueprintCallable)
	void ModiAttrValue(FName Name, float Value, TEnumAsByte<EGameplayModOp::Type> ModOp);
public:
	UPROPERTY(EditAnywhere, BlueprintReadWrite)
	FGameplayEffectCustomExecutionParameters InExecParams;
	UPROPERTY(EditAnywhere, BlueprintReadWrite)
	FGameplayEffectCustomExecutionOutput OutExecParams;
	UPROPERTY(EditAnywhere, BlueprintReadWrite)
	AActor* SourceAvatar;
	UPROPERTY(EditAnywhere, BlueprintReadWrite)
	AActor* TargetAvatar;
	UPROPERTY(EditAnywhere, BlueprintReadWrite)
	FGameplayEffectSpec Spec;
	FAggregatorEvaluateParameters EvaluateParameters;
};

UCLASS()
class IKUN_API UIkunGEExecCalc : public UGameplayEffectExecutionCalculation {
	GENERATED_BODY()
public:
	UIkunGEExecCalc(const FObjectInitializer& ObjectInitializer);
	void Execute(const FGameplayEffectCustomExecutionParameters& ExecutionParams, FGameplayEffectCustomExecutionOutput& OutExecutionOutput) const;
};
