// Fill out your copyright notice in the Description page of Project Settings.


#include "IkunGameModeBase.h"

void AIkunGameModeBase::StartPlay() {
	Super::StartPlay();
	// UE_LOG(LogTemp, Warning, TEXT("===== AIkunGameModeBase::StartPlay() ====="))
}

void AIkunGameModeBase::BeginDestroy() {
	Super::BeginDestroy();
	// UE_LOG(LogTemp, Warning, TEXT("===== AIkunGameModeBase::BeginDestroy() ====="))
}
