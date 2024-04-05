
#include "Character/IkunChrBase.h"
#include "GAS/ASC/IkunASC.h"
#include "GAS/AttrSet/IkunAttrSet.h"
#include "GameFramework/CharacterMovementComponent.h"


AIkunChrBase::AIkunChrBase() {
	PrimaryActorTick.bCanEverTick = true;

	this->AttrSet = this->CreateDefaultSubobject<UIkunAttrSet>("AttrSet");

	this->ASC = this->CreateDefaultSubobject<UIkunASC>("ASC");
	this->ASC->SetIsReplicated(true);

	this->bUseControllerRotationYaw = false;

	this->GetCharacterMovement()->bOrientRotationToMovement = true;
}

void AIkunChrBase::BeginPlay() {
	Super::BeginPlay();
	
}

void AIkunChrBase::Tick(float DeltaTime) {
	Super::Tick(DeltaTime);
}

void AIkunChrBase::SetupPlayerInputComponent(UInputComponent* PlayerInputComponent) {
	Super::SetupPlayerInputComponent(PlayerInputComponent);
}

UAbilitySystemComponent* AIkunChrBase::GetAbilitySystemComponent() const {
	return this->ASC;
}