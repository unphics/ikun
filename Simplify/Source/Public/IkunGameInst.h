// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
#include "Engine/GameInstance.h"
#include "IkunGameInst.generated.h"

/**
 * 
 */
UCLASS()
class IKUN_API UIkunGameInst : public UGameInstance {
	GENERATED_BODY()
public:
	/**
	 * 初始化顺序: 引擎启动时会执行一次PostInitProperties, 然后play时PostInitProperties->Init->OnStart
	 */
	virtual void PostInitProperties() override;
	virtual void Init() override;
	virtual void OnStart() override;
	virtual void Shutdown() override;
	virtual void OnWorldChanged(UWorld* OldWorld, UWorld* NewWorld) override;
	UFUNCTION(BlueprintImplementableEvent)
	void ReceiveOnWorldChanged(UWorld* OldWorld, UWorld* NewWorld);
};
