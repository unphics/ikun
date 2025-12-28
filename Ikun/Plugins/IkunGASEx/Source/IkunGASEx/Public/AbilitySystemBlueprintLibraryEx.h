#pragma once

#include "CoreMinimal.h"
#include "AbilitySystemBlueprintLibrary.h"
#include "AbilitySystemBlueprintLibraryEx.generated.h"

UCLASS()
class IKUNGASEX_API UAbilitySystemBlueprintLibraryEx : public UAbilitySystemBlueprintLibrary {
	GENERATED_BODY()
public:
	UFUNCTION(BlueprintCallable)
	static FGameplayTag RequestGameplayTag(FName TagName);
};
