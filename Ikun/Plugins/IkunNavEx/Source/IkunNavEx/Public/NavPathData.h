// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
#include "Object.h"
#include "NavPathData.generated.h"

DECLARE_DYNAMIC_MULTICAST_DELEGATE_OneParam(FOnPathFoundDelegate, const TArray<FVector>&, PathPoints);

class UNavigationSystemV1;

/**
 * 
 */
UCLASS()
class IKUNNAVEX_API UNavPathData : public UObject {
	GENERATED_BODY()
public:
	UFUNCTION(BlueprintCallable)
	static UNavPathData* FindPathAsync(ACharacter* InChr, FVector InStart, FVector InEnd);
	
	UFUNCTION(BlueprintCallable)
	void ClearPathData();
	UFUNCTION(BlueprintCallable)
	bool IsPathValid();
	UFUNCTION(BlueprintCallable)
	bool IsPathFinsihed();
	UFUNCTION(BlueprintCallable)
	FVector GetCurSegEnd();
	UFUNCTION(BlueprintCallable)
	void AdvanceSeg();	

	UPROPERTY(BlueprintAssignable)
	FOnPathFoundDelegate OnPathFoundEvent;
	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "NavPathData")
	TArray<FVector> _NavPoints;
	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "NavPathData")
	int _CurSegIdx;
private:
	void OnPathFound(uint32 InPathId, ENavigationQueryResult::Type InResult, TSharedPtr<FNavigationPath> InNavPath);
	TWeakObjectPtr<UNavigationSystemV1> _NavSys;
	int _PathQueryId = -1;
};
