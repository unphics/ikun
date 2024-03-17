// Fill out your copyright notice in the Description page of Project Settings.


#include "Utils/IkunFuncLIb.h"

#include "EnhancedInputComponent.h"
#include "GameplayTagContainer.h"
#include "Blueprint/UserWidget.h"
#include "Utils/UtilType.h"

UUserWidget* UIkunFuncLIb::CreateWidget(UWorld* World, UClass* Class) {
	return ::CreateWidget<UUserWidget>(World, Class);
}

void UIkunFuncLIb::BindAction(UEnhancedInputComponent* EnhancedInputComp, const UInputAction* Action,
	ETriggerEvent TriggerEvent, UObject* Object, FName FunctionName) {
	FEnhancedInputActionEventBinding& binding = EnhancedInputComp->BindAction(Action, TriggerEvent, Object, FunctionName);
	if (&binding == nullptr) {
		UE_LOG(LogTemp, Error, TEXT("Failed to bind action"))
	}
}

FGameplayTag UIkunFuncLIb::RequestGameplayTag(FName TagName) {
	return FGameplayTag::RequestGameplayTag(TagName);
}

void UIkunFuncLIb::AddTagToContainer(FGameplayTagContainer& Container, FGameplayTag& Tag) {
	Container.AddTag(Tag);
}

AActor* UIkunFuncLIb::SpawnActor(UWorld* World, UClass* Class, FTransform Transform, const FSpawnParamters& Param) {
	FActorSpawnParameters param;
	param.Name = Param.Name;
	param.Owner = Param.Owner;
	param.Instigator = Param.Instigator;
	param.Template = Param.TemplateActor;
	param.SpawnCollisionHandlingOverride = Param.CollisionHandling;
	param.OverrideLevel = Param.OverrideLevel;
	return World->SpawnActor(Class, &Transform, param);
}

FQuat UIkunFuncLIb::MakeQuatFromRot(FRotator& Rot) {
	return Rot.Quaternion();
}