// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
#include "Camera/CameraComponent.h"
#include "GameFramework/Actor.h"
#include "IkunCamera.generated.h"

class USpringArmComponent;
class UCameraComponent;

UCLASS()
class IKUN_API AIkunCamera : public AActor {
	GENERATED_BODY()
public:
	AIkunCamera();
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
