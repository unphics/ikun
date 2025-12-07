// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"

#include "NavPathFinding.generated.h"

class UNavigationSystemV1;

DECLARE_DYNAMIC_MULTICAST_DELEGATE_OneParam(FOnPathFindFinishedDelegate, const TArray<FVector>&, PathPoints);

/**
 * 
 */
UCLASS()
class IKUNNAVEX_API UNavPathFinding : public UObject {
	GENERATED_BODY()
public:
	UNavPathFinding();
	UFUNCTION(BlueprintCallable)
	static UNavPathFinding* FindPathAsync(ACharacter* InChr, FVector InStart, FVector InEnd);
	UFUNCTION(blueprintCallable)
	void CancelFind();
	UFUNCTION(blueprintCallable)
	bool IsFindValid();
	UPROPERTY(BlueprintAssignable)
	FOnPathFindFinishedDelegate OnPathFindFinishedEvent;
private:
	void OnPathComplated(uint32 InPathId, ENavigationQueryResult::Type InResult, FNavPathSharedPtr InPath);
	uint32 _PathQueryId = -1;
	TWeakObjectPtr<UNavigationSystemV1> _NavSys;
};
