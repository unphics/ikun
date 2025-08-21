// Fill out your copyright notice in the Description page of Project Settings.

#include "IkunPCBase.h"

#include "AbilitySystemComponent.h"
#include "GameFramework/Character.h"
#include "EnhancedInputLibrary.h"
#include "EnhancedInputComponent.h"
#include "IkunChrBase.h"
#include "Actor/IkunCameraBase.h"

AIkunPCBase::AIkunPCBase() {
	this->PrimaryActorTick.bCanEverTick = true;
}

void AIkunPCBase::BeginPlay() {
	Super::BeginPlay();
	this->OwnerChr = Cast<AIkunChrBase>(this->GetPawn());
}

void AIkunPCBase::Tick(float DeltaTime) {
	Super::Tick(DeltaTime);
}

void AIkunPCBase::SetupInputComponent() {
	Super::SetupInputComponent();
}