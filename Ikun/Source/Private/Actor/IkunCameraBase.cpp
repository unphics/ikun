// Fill out your copyright notice in the Description page of Project Settings.

#include "Actor/IkunCameraBase.h"

#include "Camera/CameraComponent.h"
#include "GameFramework/SpringArmComponent.h"

// Sets default values
AIkunCameraBase::AIkunCameraBase() {
	PrimaryActorTick.bCanEverTick = true;
	
	this->Mesh = this->CreateDefaultSubobject<UStaticMeshComponent>("Mesh");
	this->RootComponent = this->Mesh;
	this->Mesh->SetCollisionProfileName("NoCollision");

	this->SpringArmComp = this->CreateDefaultSubobject<USpringArmComponent>("SpringArmComp");
	this->SpringArmComp->SetupAttachment(this->RootComponent);
	this->SpringArmComp->bUsePawnControlRotation = true;
	this->SpringArmComp->TargetArmLength = 250.0f;
	this->SpringArmComp->SocketOffset = FVector(0.0f, 0.0f, 90.0f);
	this->SpringArmComp->bDoCollisionTest = false;

	this->CameraComp = CreateDefaultSubobject<UCameraComponent>("CameraComp");
	this->CameraComp->SetupAttachment(this->SpringArmComp);
}

void AIkunCameraBase::BeginPlay() {
	Super::BeginPlay();
	
}

// Called every frame
void AIkunCameraBase::Tick(float DeltaTime) {
	Super::Tick(DeltaTime);
}

