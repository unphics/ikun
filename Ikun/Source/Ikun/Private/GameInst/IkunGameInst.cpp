﻿// Fill out your copyright notice in the Description page of Project Settings.


#include "GameInst/IkunGameInst.h"

void UIkunGameInst::PostInitProperties() {
	Super::PostInitProperties();
	UE_LOG(LogTemp, Log, TEXT("===== UIkunGameInst::PostInitProperties() ====="))
}

void UIkunGameInst::Init() {
	Super::Init();
	UE_LOG(LogTemp, Warning, TEXT("===== UIkunGameInst::Init() ====="))
}

void UIkunGameInst::OnStart() {
	Super::OnStart();
	UE_LOG(LogTemp, Warning, TEXT("===== UIkunGameInst::OnStart() ====="))
}

void UIkunGameInst::Shutdown() {
	Super::Shutdown();
	UE_LOG(LogTemp, Warning, TEXT("===== UIkunGameInst::Shutdown() ====="))
}