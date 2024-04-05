// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
#include "Kismet/BlueprintFunctionLibrary.h"
#include "Engine/World.h"
#include "IkunFuncLib.generated.h"

struct FGameplayTagContainer;
struct FGameplayTag;
struct FSpawnParamters;

/**
 * 
 */
UCLASS()
class IKUN_API UIkunFuncLib : public UBlueprintFunctionLibrary {
	GENERATED_BODY()
	UFUNCTION(BlueprintCallable)
	static UUserWidget* CreateWidget(UWorld* World, UClass* Class);
	UFUNCTION(BlueprintCallable)
	static void BindAction(UEnhancedInputComponent* EnhancedInputComp, const UInputAction* Action, ETriggerEvent TriggerEvent, UObject* Object, FName FunctionName);
	UFUNCTION(BlueprintCallable)
	static FGameplayTag RequestGameplayTag(FName TagName);
	UFUNCTION(BlueprintCallable)
	static void AddTagToContainer(FGameplayTagContainer& Container, FGameplayTag& Tag);
	UFUNCTION(BlueprintCallable)
	static AActor* SpawnActor(UWorld* World, UClass* Class, FTransform Transform, const FSpawnParamters& Param);
	UFUNCTION(BlueprintCallable)
	static FQuat MakeQuatFromRot(FRotator& Rot);
};
