// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
#include "Kismet/BlueprintFunctionLibrary.h"
#include "Engine/World.h"
#include "GameplayEffectTypes.h"
#include "IkunFnLib.generated.h"

struct FGameplayTagContainer;
struct FGameplayTag;
struct FSpawnParamters;

/**
 * 
 */
UCLASS()
class IKUN_API UIkunFnLib : public UBlueprintFunctionLibrary {
	GENERATED_BODY()
public:
	UFUNCTION(BlueprintCallable)
	static int GetWorldType(UWorld* World);

	UFUNCTION(BlueprintCallable)
	static FGameplayTag RequestGameplayTag(FName TagName);

	UFUNCTION(BlueprintCallable)
	static bool HasLooseGameplayTags(AActor* Actor, const FGameplayTagContainer& GameplayTags);

	UFUNCTION(BlueprintCallable)
	static UObject* GetEffectContextOpObj(const FGameplayEffectContextHandle& ContextHandle);

	UFUNCTION(BlueprintCallable)
	static void SetEffectContextOpObj(const FGameplayEffectContextHandle& ContextHandle, UObject* OptionObject);

	UFUNCTION(BlueprintCallable)
	static const UGameplayAbility* EffectContextGetAbility(const FGameplayEffectContextHandle& ContextHandle);

	UFUNCTION(BlueprintCallable)
	static bool IsInSession(UObject* WorldContextObject, FName SystemName = NAME_None);
};
