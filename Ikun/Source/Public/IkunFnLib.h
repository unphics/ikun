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
	static UUserWidget* CreateWidget(UWorld* World, UClass* Class);

	UFUNCTION(BlueprintCallable)
	static void BindAction(UEnhancedInputComponent* EnhancedInputComp, const UInputAction* Action, ETriggerEvent TriggerEvent, UObject* Object, FName FunctionName);
	
	UFUNCTION(BlueprintCallable)
	static int GetWorldType(UWorld* World);

#pragma region GAS
	UFUNCTION(BlueprintCallable)
	static FGameplayTag RequestGameplayTag(FName TagName);

	UFUNCTION(BlueprintCallable)
	static bool IsGameplayTagEqual(FGameplayTag TagA, FGameplayTag TagB);
	
	UFUNCTION(BlueprintCallable)
	static void AddTagToContainer(FGameplayTagContainer& Container, FGameplayTag& Tag);

	UFUNCTION(BlueprintCallable)
	static bool HasLooseGameplayTags(AActor* Actor, const FGameplayTagContainer& GameplayTags);

	UFUNCTION(BlueprintCallable)
	static UObject* GetEffectContextOpObj(const FGameplayEffectContextHandle& ContextHandle);

	UFUNCTION(BlueprintCallable)
	static void SetEffectContextOpObj(const FGameplayEffectContextHandle& ContextHandle, UObject* OptionObject);
#pragma endregion GAS

	UFUNCTION(BlueprintCallable)
	static AActor* SpawnActor(UWorld* World, UClass* Class, FTransform Transform, const FSpawnParamters& Param);

	UFUNCTION(BlueprintCallable)
	static const UGameplayAbility* EffectContextGetAbility(const FGameplayEffectContextHandle& ContextHandle);

#pragma endregion
	
	UFUNCTION(BlueprintCallable)
	static FQuat MakeQuatFromRot(FRotator& Rot);

	//UFUNCTION(BlueprintCallable)
	//static void CustomPassTest(UTextureRenderTarget2D* RT);
#pragma region python
	/*
	for x in sorted(dir(unreal.IkunFnLib)):
		print(x)
	*/
	UFUNCTION(BlueprintCallable)
	static void CalledFromPython(FString InStr);
	UFUNCTION(BlueprintCallable)
	static void SetFloderColor(FString Path, FLinearColor Color);
#pragma endregion

	UFUNCTION(BlueprintCallable)
	static bool ReplaceInputs(AActor* Actor, UInputComponent* InputComponent);
	
	UFUNCTION(BlueprintCallable)
	static bool IsInSession();
};
