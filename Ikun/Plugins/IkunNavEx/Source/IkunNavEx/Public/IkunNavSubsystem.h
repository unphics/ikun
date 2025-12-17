/**
* -----------------------------------------------------------------------------
 *  File        : IkunNavSubsystem.h
 *  Author      : zhengyanshuai
 *  Date        : Tue Dec 16 2025 06:55:42 GMT+0800 (中国标准时间)
 *  Description : 
 *  License     : MIT License
 * -----------------------------------------------------------------------------
 *  Copyright (c) 2025 zhengyanshuai
 * -----------------------------------------------------------------------------
 */
#pragma once

#include "CoreMinimal.h"
#include "IkunNavSubsystem.generated.h"

class UNavSteering;
/**
 * 
 */
UCLASS()
class IKUNNAVEX_API UIkunNavSubsystem : public UWorldSubsystem {
	GENERATED_BODY()
public:
	// override
	virtual void Initialize(FSubsystemCollectionBase& Collection) override;
	virtual void Deinitialize() override;
	virtual bool ShouldCreateSubsystem() const { return true; }

	// 池化接口
	UFUNCTION(BlueprintCallable)
	UNavSteering* RequestMoveToActor(ACharacter* InOwnerChr, AActor* InTargetActor, float InAcceptRadius);
	UFUNCTION(BlueprintCallable)
	UNavSteering* RequestMoveToLoc(ACharacter* InOwnerChr, FVector InTargetLoc, float InAcceptRadius);
	UFUNCTION(BlueprintCallable)
	void ReturnSteering(UNavSteering* InSteeringObject);

	UPROPERTY(Transient)
	TArray<UNavSteering*> SteeringPool;
	UPROPERTY(Transient)
	TArray<UNavSteering*> ActiveSteerings;
};
