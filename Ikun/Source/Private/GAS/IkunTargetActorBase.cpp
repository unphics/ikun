// Fill out your copyright notice in the Description page of Project Settings.


#include "GAS/IkunTargetActorBase.h"

#include "GameplayAbilitySpec.h"

AIkunTargetActorBase::AIkunTargetActorBase(const FObjectInitializer& ObjectInitializer)
	: Super(ObjectInitializer){
	this->bDestroyOnConfirmation = false;
}

void AIkunTargetActorBase::StartTargeting(UGameplayAbility* Ability) {
	this->OnPreStartTargeting(Ability);
	Super::StartTargeting(Ability);
	this->OnPostStartTargeting(Ability);
}

void AIkunTargetActorBase::ConfirmTargetingAndContinue() {
	this->OnPreConfirmTargetingAndContinue();
	Super::ConfirmTargetingAndContinue();
	//this->OnPostConfirmTargetingAndContinue();
}

void AIkunTargetActorBase::BrostcastTargetData(FGameplayAbilityTargetDataHandle& Handle) {
	this->TargetDataReadyDelegate.Broadcast(Handle);
}
