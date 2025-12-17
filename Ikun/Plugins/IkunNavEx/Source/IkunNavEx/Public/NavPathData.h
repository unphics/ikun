/**
 * -----------------------------------------------------------------------------
 *  File        : NavPathData.h
 *  Author      : zhengyanshuai
 *  Date        : Wed Dec 10 2025 22:54:33 GMT+0800 (中国标准时间)
 *  Description :
 *  Todo		: 放入Pool
 *  License     : MIT License
 * -----------------------------------------------------------------------------
 *  Copyright (c) 2025 zhengyanshuai
 * -----------------------------------------------------------------------------
 */

#pragma once

#include "CoreMinimal.h"
#include "NavPathData.generated.h"

DECLARE_DYNAMIC_MULTICAST_DELEGATE_TwoParams(FOnPathFoundDelegate, const TArray<FVector>&, PathPoints, bool, bSuccess);

class UNavigationSystemV1;

/**
 * 
 */
UCLASS(BlueprintType)
class IKUNNAVEX_API UNavPathData : public UObject {
	GENERATED_BODY()
public:
	virtual void BeginDestroy() override;
	
public:
	UFUNCTION(BlueprintCallable)
	static UNavPathData* FindPathAsync(ACharacter* InChr, FVector InStart, FVector InEnd);
	
	UFUNCTION(BlueprintCallable)
	void ClearPathData();
	UFUNCTION(BlueprintCallable)
	void AdvanceSeg();
	UFUNCTION(BlueprintCallable)
	void CancelFinding();
	UFUNCTION(BlueprintCallable)
	void SetFirstPoint(const FVector& FirstPoint);
	UFUNCTION(BlueprintPure)
	bool IsPathValid() const;
	UFUNCTION(BlueprintPure)
	bool IsPathFinsihed() const;
	UFUNCTION(BlueprintPure)
	FVector GetCurSegEnd() const;
	UFUNCTION(BlueprintPure)
	FVector CalcDirToSegEnd(const FVector& Loc) const;
	UFUNCTION(BlueprintPure)
	bool IsFinding() const;

	UPROPERTY(BlueprintAssignable)
	FOnPathFoundDelegate OnPathFoundEvent;
	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "NavPathData")
	TArray<FVector> NavPoints;
	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "NavPathData")
	int CurSegIdx;
	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "NavPathData")
	bool bHasFirst;
	
	virtual void OnPathFound(uint32 InPathId, ENavigationQueryResult::Type InResult, TSharedPtr<FNavigationPath> InNavPath);
private:
	TWeakObjectPtr<UNavigationSystemV1> _NavSys;
	int _PathQueryId = -1;
};
