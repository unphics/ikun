
#include "IkunCamera.h"

#include "GameFramework/SpringArmComponent.h"


AIkunCamera::AIkunCamera() {
	PrimaryActorTick.bCanEverTick = true;

	this->Mesh = this->CreateDefaultSubobject<UStaticMeshComponent>("Mesh");
	this->RootComponent = this->Mesh;
	this->Mesh->SetCollisionProfileName("NoCollision");

	this->SpringArmComp = this->CreateDefaultSubobject<USpringArmComponent>("SpringArmComp");
	this->SpringArmComp->SetupAttachment(this->RootComponent);
	this->SpringArmComp->bUsePawnControlRotation = true;
	this->SpringArmComp->TargetArmLength = 350.0f;
	this->SpringArmComp->SocketOffset = FVector(0.0f, 0.0f, 90.0f);
	this->SpringArmComp->bDoCollisionTest = false;
	
	this->CameraComp = CreateDefaultSubobject<UCameraComponent>("CameraComp");
	this->CameraComp->SetupAttachment(this->SpringArmComp);
}

void AIkunCamera::BeginPlay() {
	Super::BeginPlay();
}

void AIkunCamera::Tick(float DeltaTime) {
	Super::Tick(DeltaTime);
}

