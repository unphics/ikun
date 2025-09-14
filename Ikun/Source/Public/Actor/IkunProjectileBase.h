// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
#include "GameFramework/Actor.h"
#include "IkunProjectileBase.generated.h"

class UProjectileMovementComponent;
class USphereComponent;
class UParticleSystemComponent;

UCLASS()
class IKUN_API AIkunProjectileBase : public AActor {
	GENERATED_BODY()
public:
	AIkunProjectileBase();
	virtual void BeginPlay() override;
	virtual void Tick(float DeltaTime) override;
protected:
	UPROPERTY(VisibleAnywhere, BlueprintReadWrite)
	USphereComponent* SphereComp;
	UPROPERTY(VisibleAnywhere)
	UProjectileMovementComponent* ProjectileMoveComp;
	UPROPERTY(VisibleAnywhere)
	UParticleSystemComponent* ParticleSysComp;
private:
	UFUNCTION(BlueprintCallable)
	void OnActorBeginOverlap(UPrimitiveComponent* OverlappedComponent, AActor* OtherActor, UPrimitiveComponent* OtherComp, int32 OtherBodyIndex, bool bFromSweep, const FHitResult & SweepResult);
};
