// Fill out your copyright notice in the Description page of Project Settings.


#include "IkunGameInst.h"

void UIkunGameInst::PostInitProperties() {
	Super::PostInitProperties();
	// UE_LOG(LogTemp, Log, TEXT("===== UIkunGameInst::PostInitProperties() ====="))
}

void UIkunGameInst::Init() {
	Super::Init();
	// UE_LOG(LogTemp, Warning, TEXT("===== UIkunGameInst::Init() ====="))
	FCoreUObjectDelegates::PreLoadMap.AddUObject(this, &UIkunGameInst::OnPreLoadMap);
	FCoreUObjectDelegates::PostLoadMapWithWorld.AddUObject(this, &UIkunGameInst::OnPostLoadMap);
}

void UIkunGameInst::OnStart() {
	Super::OnStart();
	// UE_LOG(LogTemp, Warning, TEXT("===== UIkunGameInst::OnStart() ====="))
}

void UIkunGameInst::Shutdown() {
	Super::Shutdown();
	// UE_LOG(LogTemp, Warning, TEXT("===== UIkunGameInst::Shutdown() ====="))
	FCoreUObjectDelegates::PreLoadMap.RemoveAll(this);
	FCoreUObjectDelegates::PostLoadMapWithWorld.RemoveAll(this);
}

void UIkunGameInst::OnWorldChanged(UWorld* OldWorld, UWorld* NewWorld) {
	this->ReceiveOnWorldChanged(OldWorld, NewWorld);
	if (OldWorld) {
		OldWorld->OnWorldBeginPlay.RemoveAll(this);
		OldWorld->OnActorsInitialized.RemoveAll(this);
	}
	if (NewWorld) {
		NewWorld->OnWorldBeginPlay.AddUObject(this, &UIkunGameInst::OnWorldBeginPlay);
		NewWorld->OnActorsInitialized.AddUObject(this, &UIkunGameInst::OnActorsInitialized);
	}
}

void UIkunGameInst::OnActorsInitialized(const FActorsInitializedParams&) {
	this->ReceiveOnActorsInitialized();
}