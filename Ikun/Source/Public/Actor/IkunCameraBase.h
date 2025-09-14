// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
#include "GameFramework/Actor.h"
#include "IkunCameraBase.generated.h"

class AIkunPCBase;
class USpringArmComponent;
class UCameraComponent;

UCLASS()
class IKUN_API AIkunCameraBase : public AActor {
	GENERATED_BODY()
public:
	AIkunCameraBase();
	virtual void BeginPlay() override;
	virtual void Tick(float DeltaTime) override;
protected:
	UPROPERTY(EditAnywhere, BlueprintReadWrite)
	UStaticMeshComponent* Mesh;
	UPROPERTY(EditAnywhere, BlueprintReadWrite)
	USpringArmComponent* SpringArmComp;
	UPROPERTY(EditAnywhere, BlueprintReadWrite)
	UCameraComponent* CameraComp;
};


