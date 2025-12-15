/**
* -----------------------------------------------------------------------------
 *  File        : NavSteering.h
 *  Author      : zhengyanshuai
 *  Date        : Thu Dec 11 2025 22:18:27 GMT+0800 (中国标准时间)
 *  Description :
 *  Todo		: 改造成Base, 让更多导航寻路需求从这里继承
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
class UMoveStuckDetector;

UENUM(BlueprintType)
enum class ENavSteerResult: uint8 {
	Success,
	Lost,
	Stuck,
	Cancelled,
};

DECLARE_DYNAMIC_MULTICAST_DELEGATE_OneParam(FOnNavFinishedDelegate, ENavSteerResult, NavSteerResult);


UCLASS(BlueprintType, Blueprintable)
class IKUNNAVEX_API UNavSteering : public UObject, public FTickableObjectBase {
	GENERATED_BODY()
	UNavSteering();
public:
	// --- 公共API ---
	UFUNCTION(BlueprintCallable)
	bool TryMoveToActor(ACharacter* InOwnerChr, AActor* InTargetActor, float InAcceptRadius);
	UFUNCTION(BlueprintCallable)
	bool TryMoveToLoc(ACharacter* InOwnerChr, FVector InTargetLoc, float InAcceptRadius);
	UFUNCTION(BlueprintCallable)
	void CancelMove();
	UFUNCTION(BlueprintPure)
	FVector GetSteerTargetLoc() const;
	UFUNCTION(BlueprintPure)
	bool HasReached() const;
	UFUNCTION(BlueprintCallable)
	void DrawDebugPath();

	void ResetInternal();
	
	// --- 委托事件 ---
	UPROPERTY(BlueprintAssignable)
	FOnNavFinishedDelegate OnNavFinishedEvent;

	// --- 核心组件 ---
	UPROPERTY(BlueprintReadOnly)
	UNavPathData* NavPathData;
	UPROPERTY(BlueprintReadOnly)
	UMoveStuckDetector* MoveStuckDetector;
	
	// --- 内部回调 ---
	UFUNCTION()
	void _OnPathFound_First(const TArray<FVector>& InPathPoints, bool bSuccess);
	UFUNCTION()
	void _OnPathFound_Second(const TArray<FVector>& InPathPoints, bool bSuccess);
	UFUNCTION()
	void OnPathRefreshed(const TArray<FVector>& InPathPoints, bool bSuccess);

	// override
	virtual bool IsTickable() const override;
	virtual TStatId GetStatId() const override { RETURN_QUICK_DECLARE_CYCLE_STAT(UNavSteering, STATGROUP_Tickables); }
	virtual void Tick(float DeltaTime) override;

	// --- 内部逻辑虚函数 ---
	virtual void SteerBegin();
	virtual void SteerEnd();

	// --- 配置参数 ---
	UPROPERTY(EditAnywhere, BlueprintReadWrite)
	float NavPathRefreshInterval = 0.5f;
	UPROPERTY(EditAnywhere, BlueprintReadWrite)
	float AcceptRadius = 50.0f;
	UPROPERTY(EditAnywhere, BlueprintReadWrite)
	bool bShowDebugLines = false;
	
	// --- 运行时状态 ---
	UPROPERTY(Transient)
	ACharacter* OwnerChr;
	UPROPERTY(Transient)
	AActor* GoalActor;
	
	FVector GoalLocation;
	FVector _CachedGoalLoc;
	bool _bIsActorTarget = false;

	float _CurPathRefreshTimeCount = 0.0f;
	bool _bSteeringActive = false;

	UPROPERTY()
	UNavPathData* _PendingNavData;
};