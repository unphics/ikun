#include "AbilitySystemBlueprintLibraryEx.h"

FGameplayTag UAbilitySystemBlueprintLibraryEx::RequestGameplayTag(FName TagName) {
	return FGameplayTag::RequestGameplayTag(TagName);
}
