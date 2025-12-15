/**
* -----------------------------------------------------------------------------
 *  File        : IkunNavSubsystem.cpp
 *  Author      : zhengyanshuai
 *  Date        : Tue Dec 16 2025 06:55:42 GMT+0800 (中国标准时间)
 *  Description : 
 *  License     : MIT License
 * -----------------------------------------------------------------------------
 *  Copyright (c) 2025 zhengyanshuai
 * -----------------------------------------------------------------------------
 */
#include "IkunNavSubsystem.h"

#include "NavSteering.h"
#include "Kismet/KismetSystemLibrary.h"

void UIkunNavSubsystem::Initialize(FSubsystemCollectionBase& Collection) {
	Super::Initialize(Collection);
	UE_LOG(LogTemp, Log, TEXT("UIkunNavSubsystem::Initialize()"));
}

void UIkunNavSubsystem::Deinitialize() {
	Super::Deinitialize();
	UE_LOG(LogTemp, Log, TEXT("UIkunNavSubsystem::Deinitialize()"));
}

UNavSteering* UIkunNavSubsystem::RequestMoveToActor(ACharacter* InOwnerChr, AActor* InTargetActor, float InAcceptRadius) {
	UNavSteering *navSteering = nullptr;
	if (this->SteeringPool.Num() > 0) {
		navSteering = this->SteeringPool.Pop();
	} else {
		navSteering = NewObject<UNavSteering>(this);
	}
	if (navSteering) {
		this->ActiveSteerings.Add(navSteering);
		if (!navSteering->TryMoveToActor(InOwnerChr, InTargetActor, InAcceptRadius)) {
			this->ReturnSteering(navSteering);
			navSteering = nullptr;
		}
	}
	return navSteering;
}

UNavSteering* UIkunNavSubsystem::RequestMoveToLoc(ACharacter* InOwnerChr, FVector InTargetLoc, float InAcceptRadius) {
	UNavSteering *navSteering = nullptr;
	if (this->SteeringPool.Num() > 0) {
		navSteering = this->SteeringPool.Pop();
	} else {
		navSteering = NewObject<UNavSteering>(this);
	}
	if (navSteering) {
		this->ActiveSteerings.Add(navSteering);
		if (!navSteering->TryMoveToLoc(InOwnerChr, InTargetLoc, InAcceptRadius)) {
			this->ReturnSteering(navSteering);
			navSteering = nullptr;
		}
	}
	return navSteering;
}

void UIkunNavSubsystem::ReturnSteering(UNavSteering* InSteeringObject) {
	if (!UKismetSystemLibrary::IsValid(InSteeringObject)) {
		return;
	}
	this->ActiveSteerings.Remove(InSteeringObject);
	if (this->SteeringPool.Contains(InSteeringObject)) {
		return;
	}
	InSteeringObject->ResetInternal();
	this->SteeringPool.Push(InSteeringObject);
}
