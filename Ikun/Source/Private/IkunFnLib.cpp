// Fill out your copyright notice in the Description page of Project Settings.


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

#include "UnLuaBase.h"
#include "Lua/lua-5.4.4/src/lua.h"


UUserWidget* UIkunFnLib::CreateWidget(UWorld* World, UClass* Class) {
	return ::CreateWidget<UUserWidget>(World, Class);
}

void UIkunFnLib::BindAction(UEnhancedInputComponent* EnhancedInputComp, const UInputAction* Action,
	ETriggerEvent TriggerEvent, UObject* Object, FName FunctionName) {
	FEnhancedInputActionEventBinding& binding = EnhancedInputComp->BindAction(Action, TriggerEvent, Object, FunctionName);
	if (&binding == nullptr) {
		UE_LOG(LogTemp, Error, TEXT("Failed to bind action"))
	}
}

int UIkunFnLib::GetWorldType(UWorld* World) {
	return World->WorldType;
}

FGameplayTag UIkunFnLib::RequestGameplayTag(FName TagName) {
	return FGameplayTag::RequestGameplayTag(TagName);
}

bool UIkunFnLib::IsGameplayTagEqual(FGameplayTag TagA, FGameplayTag TagB) {
	return TagA == TagB;
}

void UIkunFnLib::AddTagToContainer(FGameplayTagContainer& Container, FGameplayTag& Tag) {
	Container.AddTag(Tag);
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

AActor* UIkunFnLib::SpawnActor(UWorld* World, UClass* Class, FTransform Transform, const FSpawnParamters& Param) {
	FActorSpawnParameters param;
	param.Name = Param.Name;
	param.Owner = Param.Owner;
	param.Instigator = Param.Instigator;
	param.Template = Param.TemplateActor;
	param.SpawnCollisionHandlingOverride = Param.CollisionHandling;
	param.OverrideLevel = Param.OverrideLevel;
	return World->SpawnActor(Class, &Transform, param);
}

FQuat UIkunFnLib::MakeQuatFromRot(FRotator& Rot) {
	return Rot.Quaternion();
}

void UIkunFnLib::CalledFromPython(FString InStr) {
	UE_LOG(LogTemp, Error, TEXT("%s"), *InStr);
}

void UIkunFnLib::SetFloderColor(FString Path, FLinearColor Color) {
	GConfig->SetString(TEXT("PathColor"), *Path, *Color.ToString(), GEditorPerProjectIni);
}

//#include "CustomRenderingPass.h"
//#include "RHICommandList.h"
//
//void UIkunFnLib::CustomPassTest(UTextureRenderTarget2D* RT) {
//	if (RT) {
//		FCustomRenderingPassModule& Module = FModuleManager::LoadModuleChecked<FCustomRenderingPassModule>("CustomRenderingPass");
//		Module.RenderCustomPass(RT);
//	}
//}


bool UIkunFnLib::ReplaceInputs(AActor* Actor, UInputComponent* InputComponent) {
	lua_State* L = UnLua::GetState();
	UnLua::FLuaEnv* Env = UnLua::FLuaEnv::FindEnv(L);
	return Env->GetManager()->ReplaceInputs(Actor, InputComponent);
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