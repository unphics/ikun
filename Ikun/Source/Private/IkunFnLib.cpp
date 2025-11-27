#include "IkunFnLib.h"

#include "EnhancedInputComponent.h"
#include "GameplayTagContainer.h"
//#include "../../../../Plugins/CustomRenderingPass/Source/CustomRenderingPass/Public/CustomRenderingPass.h"
#include "Blueprint/UserWidget.h"
#include "UtilType.h"
#include "Misc/ConfigCacheIni.h"
#include "AbilitySystemComponent.h"
#include "AbilitySystemBlueprintLibrary.h"
#include "ikun_cpp_utl.h"
#include "LuaEnv.h"
#include "Online.h"
#include "GAS/IkunAbilityTypes.h"
#include "Interfaces/OnlineSessionInterface.h"
#include "OnlineSubsystem.h"
#include "OnlineSubsystemUtils.h"

int UIkunFnLib::GetWorldType(UWorld* World) {
	return World->WorldType;
}

FGameplayTag UIkunFnLib::RequestGameplayTag(FName TagName) {
	return FGameplayTag::RequestGameplayTag(TagName);
}

IKUN_STEAL_PRIVATE(UAbilitySystemComponent, GetReplicatedLooseTags_Mutable)

bool UIkunFnLib::HasLooseGameplayTags(AActor* Actor, const FGameplayTagContainer& GameplayTags) {
	if (UAbilitySystemComponent* AbilitySysComp = UAbilitySystemBlueprintLibrary::GetAbilitySystemComponent(Actor)) {
		auto fn = ikun_steal_GetReplicatedLooseTags_Mutable(*AbilitySysComp);
		FMinimalReplicationTagCountMap& tagCountMap = ::std::mem_fn(fn)(*AbilitySysComp);
		for (const FGameplayTag& Tag : GameplayTags) {
			if (tagCountMap.TagMap.FindOrAdd(Tag) > 0) {
				return true;
			}
		}
	}
	return false;
}

UObject* UIkunFnLib::GetEffectContextOpObj(const FGameplayEffectContextHandle& ContextHandle) {
	auto ctx = static_cast<const FIkunGameplayEffectContext*>(ContextHandle.Get());
	return ctx->OptionalObject;
}

void UIkunFnLib::SetEffectContextOpObj(const FGameplayEffectContextHandle& ContextHandle, UObject* OptionObject){
	auto ctx = const_cast<FIkunGameplayEffectContext*>(static_cast<const FIkunGameplayEffectContext*>(ContextHandle.Get()));
	ctx->OptionalObject = OptionObject;
}

const UGameplayAbility* UIkunFnLib::EffectContextGetAbility(const FGameplayEffectContextHandle& ContextHandle) {
	return ContextHandle.GetAbility();
}

bool UIkunFnLib::IsInSession(UObject* WorldContextObject, FName SystemName) {
	IOnlineSubsystem* OnlineSub = ::Online::GetSubsystem(GEngine->GetWorldFromContextObject(WorldContextObject, EGetWorldErrorMode::ReturnNull), SystemName);
	if (OnlineSub) {
		auto sessionInt = OnlineSub->GetSessionInterface();
		auto n = sessionInt->GetNumSessions();
		return n > 0;
	}
	return false;
}