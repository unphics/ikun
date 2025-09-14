// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
#include "GameFramework/PlayerController.h"
#include "InputActionValue.h"
#include "IkunPCBase.generated.h"

class AIkunChrBase;
class AIkunCameraBase;
class UInputMapping;
class UInputMappingContext;
class UInputAction;
/**
 * 
 */
UCLASS()
class IKUN_API AIkunPCBase : public APlayerController {
	GENERATED_BODY()
public:
	AIkunPCBase();
	virtual void BeginPlay() override;
	virtual void Tick(float DeltaTime) override;
	virtual void SetupInputComponent() override;
public:
	UPROPERTY(EditAnywhere, BlueprintReadWrite)
	AIkunChrBase* OwnerChr;
};
