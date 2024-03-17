// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
#include "GameFramework/GameModeBase.h"
#include "IkunGameModeBase.generated.h"

/**
 * 
 */
UCLASS()
class IKUN_API AIkunGameModeBase : public AGameModeBase {
	GENERATED_BODY()
public:
	virtual void StartPlay() override;
	virtual void BeginDestroy() override;
};
