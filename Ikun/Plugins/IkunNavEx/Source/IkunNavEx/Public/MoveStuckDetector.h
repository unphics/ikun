/**
 * -----------------------------------------------------------------------------
 *  File        : MoveStuckDetector.h
 *  Author      : zhengyanshuai
 *  Date        : Wed Dec 10 2025 22:54:33 GMT+0800 (中国标准时间)
 *  Description : 
 *  License     : MIT License
 * -----------------------------------------------------------------------------
 *  Copyright (c) 2025 zhengyanshuai
 * -----------------------------------------------------------------------------
 */
#pragma once

#include "CoreMinimal.h"
#include "Object.h"
#include "MoveStuckDetector.generated.h"

/**
 * 
 */
UCLASS()
class IKUNNAVEX_API UMoveStuckDetector : public UObject {
	GENERATED_BODY()
public:
	UFUNCTION(BlueprintCallable)
	static UMoveStuckDetector* CreateDetector(float MaxStuckTime = 0.5, const FVector& ChrAgentLoc = FVector::ZeroVector);
	UFUNCTION(BlueprintCallable)
	bool TickMonitor(float DeltaTime, const FVector& ChrAgentLoc);

	UPROPERTY(BlueprintReadWrite, EditAnywhere)
	float _MaxStuckTime;
	UPROPERTY(BlueprintReadWrite, EditAnywhere)
	FVector _MoveStuckLoc;
	UPROPERTY(BlueprintReadWrite, EditAnywhere)
	float _CurStuckTime;
};
