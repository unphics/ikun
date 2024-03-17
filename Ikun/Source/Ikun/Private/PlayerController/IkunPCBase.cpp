// Fill out your copyright notice in the Description page of Project Settings.

#include "PlayerController/IkunPCBase.h"

#include "AbilitySystemComponent.h"
#include "GameFramework/Character.h"
#include "EnhancedInputLibrary.h"
#include "EnhancedInputComponent.h"
#include "Character/IkunChrBase.h"
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

void AIkunPCBase::InitCamera() {
	FActorSpawnParameters SpawnParam;
	SpawnParam.SpawnCollisionHandlingOverride = ESpawnActorCollisionHandlingMethod::AlwaysSpawn;
	auto location = this->K2_GetActorLocation();
	auto rotation = this->K2_GetActorRotation();
	this->ViewCamera = Cast<AIkunCameraBase>(GetWorld()->SpawnActor(this->CameraActorClass, &location, &rotation, SpawnParam));
	if (this->ViewCamera) {
		this->SetViewTarget(this->ViewCamera);
		FAttachmentTransformRules AttachRule(EAttachmentRule::SnapToTarget, EAttachmentRule::SnapToTarget, EAttachmentRule::SnapToTarget, false);
		this->ViewCamera->AttachToActor(this, AttachRule);
	} else {
		UE_LOG(LogTemp, Error, TEXT("Failed To Spawn Player Camera !!"))
	}
}
