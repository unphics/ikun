// Fill out your copyright notice in the Description page of Project Settings.


#include "IkunFuncLib.h"

#include "EnhancedInputComponent.h"
#include "GameplayTagContainer.h"
//#include "../../../../Plugins/CustomRenderingPass/Source/CustomRenderingPass/Public/CustomRenderingPass.h"
#include "Blueprint/UserWidget.h"
#include "UtilType.h"
#include "Misc/ConfigCacheIni.h"

UUserWidget* UIkunFuncLib::CreateWidget(UWorld* World, UClass* Class) {
	return ::CreateWidget<UUserWidget>(World, Class);
}

void UIkunFuncLib::BindAction(UEnhancedInputComponent* EnhancedInputComp, const UInputAction* Action,
	ETriggerEvent TriggerEvent, UObject* Object, FName FunctionName) {
	FEnhancedInputActionEventBinding& binding = EnhancedInputComp->BindAction(Action, TriggerEvent, Object, FunctionName);
	if (&binding == nullptr) {
		UE_LOG(LogTemp, Error, TEXT("Failed to bind action"))
	}
}

FGameplayTag UIkunFuncLib::RequestGameplayTag(FName TagName) {
	return FGameplayTag::RequestGameplayTag(TagName);
}

bool UIkunFuncLib::IsGameplayTagEqual(FGameplayTag TagA, FGameplayTag TagB) {
	return TagA == TagB;
}

void UIkunFuncLib::AddTagToContainer(FGameplayTagContainer& Container, FGameplayTag& Tag) {
	Container.AddTag(Tag);
}

AActor* UIkunFuncLib::SpawnActor(UWorld* World, UClass* Class, FTransform Transform, const FSpawnParamters& Param) {
	FActorSpawnParameters param;
	param.Name = Param.Name;
	param.Owner = Param.Owner;
	param.Instigator = Param.Instigator;
	param.Template = Param.TemplateActor;
	param.SpawnCollisionHandlingOverride = Param.CollisionHandling;
	param.OverrideLevel = Param.OverrideLevel;
	return World->SpawnActor(Class, &Transform, param);
}

FQuat UIkunFuncLib::MakeQuatFromRot(FRotator& Rot) {
	return Rot.Quaternion();
}

void UIkunFuncLib::CalledFromPython(FString InStr) {
	UE_LOG(LogTemp, Error, TEXT("%s"), *InStr);
}

void UIkunFuncLib::SetFloderColor(FString Path, FLinearColor Color) {
	GConfig->SetString(TEXT("PathColor"), *Path, *Color.ToString(), GEditorPerProjectIni);
}

//#include "CustomRenderingPass.h"
//#include "RHICommandList.h"
//
//void UIkunFuncLib::CustomPassTest(UTextureRenderTarget2D* RT) {
//	if (RT) {
//		FCustomRenderingPassModule& Module = FModuleManager::LoadModuleChecked<FCustomRenderingPassModule>("CustomRenderingPass");
//		Module.RenderCustomPass(RT);
//	}
//}