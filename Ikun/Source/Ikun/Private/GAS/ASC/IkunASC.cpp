// Fill out your copyright notice in the Description page of Project Settings.

#include "GAS/ASC/IkunASC.h"

#include "AbilitySystemGlobals.h"

UIkunASC::UIkunASC() {
	this->PrimaryComponentTick.bCanEverTick = true;
}

void UIkunASC::BeginPlay() {
	Super::BeginPlay();
}

void UIkunASC::TickComponent(float DeltaTime, ELevelTick TickType, FActorComponentTickFunction* ThisTickFunction) {
	Super::TickComponent(DeltaTime, TickType, ThisTickFunction);
}

UIkunASC* UIkunASC::GetAscFromActor(const AActor* Actor, bool bLookForComp) {
	return Cast<UIkunASC>(UAbilitySystemGlobals::GetAbilitySystemComponentFromActor(Actor, bLookForComp));
}
