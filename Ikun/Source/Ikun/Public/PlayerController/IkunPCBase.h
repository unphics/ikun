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
protected:
	UFUNCTION(BlueprintCallable)
	void InitCamera();
	
public:
	// TODO 更换为IKUNCharacterBase
	UPROPERTY(EditAnywhere, BlueprintReadWrite)
	AIkunChrBase* OwnerChr;

	UPROPERTY(EditAnywhere, BlueprintReadWrite)
	TSubclassOf<AIkunCameraBase> CameraActorClass;
	
	UPROPERTY(EditAnywhere, BlueprintReadWrite)
	AIkunCameraBase* ViewCamera;
};
