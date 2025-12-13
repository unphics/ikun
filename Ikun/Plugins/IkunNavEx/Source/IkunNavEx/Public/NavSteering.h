/**
* -----------------------------------------------------------------------------
 *  File        : NavSteering.h
 *  Author      : zhengyanshuai
 *  Date        : Thu Dec 11 2025 22:18:27 GMT+0800 (中国标准时间)
 *  Description : 
 *  License     : MIT License
 * -----------------------------------------------------------------------------
 *  Copyright (c) 2025 zhengyanshuai
 * -----------------------------------------------------------------------------
 */
#pragma once

#include "CoreMinimal.h"
#include "Object.h"
#include "NavSteering.generated.h"

class ACharacter;
class UNavPathData;

UENUM()
enum ENavSteerResult: uint8 {
	Success,
	Lost,
	Stuck,
	Cancelled,
};

DECLARE_DYNAMIC_MULTICAST_DELEGATE_OneParam(FOnNavFinishedDelegate, ENavSteerResult, NavSteerResult)


UCLASS()
class IKUNNAVEX_API UNavSteering : public UObject {
	GENERATED_BODY()
	UNavSteering();
public:
	UFUNCTION(BlueprintCallable)
	static UNavSteering* RequestMoveToActor(AActor* InTargetActor, float InAcceptRadius);
	UFUNCTION(BlueprintCallable)
	static UNavSteering* RequestMoveToLoc(ACharacter* InOwnerChr, const FVector& InTargetLoc, float InAcceptRadius);
	UFUNCTION(BlueprintCallable)
	void CancelMove();
	// UFUNCTION(BlueprintCallable)
	// void PauseMove();
	// UFUNCTION(BlueprintCallable)
	// void ContinueMove();
	UFUNCTION(BlueprintCallable)
	const FVector& GetSteerTargetLoc() const;
	UFUNCTION(BlueprintCallable)
	bool HasReached(float RadiusCorr = 0.1f) const;
	
public:
	UPROPERTY(BlueprintAssignable)
	FOnNavFinishedDelegate OnNavFinishedEvent;
	UPROPERTY(BlueprintReadWrite)
	UNavPathData* NavPathData;
	UPROPERTY(BlueprintReadWrite)
	UMoveStuckDetector* MoveStuckDetector;
	
protected:
	UFUNCTION()
	void _OnPathFound_First(const TArray<FVector>& InPathPoints, bool bSuccess);
	UFUNCTION()
	void _OnPathFound_Second(const TArray<FVector>& InPathPoints, bool bSuccess);
	void _SteerBegin();
	void _SteerEnd();
	void _SteerTick();
	
protected:
	float _DeltaTime = 0.1f;
	FTimerHandle _TimerHandle;
	
	float AcceptRadius;
	FVector CachedTarget;
	FVector _TargetLoc;
	AActor* _TargetActor;
	bool _bIsActorTarget = false;
	
	ACharacter* _OwnerChr;
};