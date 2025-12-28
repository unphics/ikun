#include "TargetActorBase.h"

ATargetActorBase::ATargetActorBase() {
	PrimaryActorTick.bCanEverTick = true;
}

void ATargetActorBase::K2_ConfirmTargeting() {
	this->ConfirmTargeting();
}

void ATargetActorBase::StartTargeting(UGameplayAbility* Ability) {
	Super::StartTargeting(Ability);
	this->OnStartTargeting(Ability);
}

void ATargetActorBase::ConfirmTargetingAndContinue() {
	this->OnConfirmTargetingAndContinue();
}