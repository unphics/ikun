// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
#include "GameFramework/Character.h"
#include "AbilitySystemInterface.h"
#include "IkunChrBase.generated.h"

class UIkunAttrSet;
class UIkunASC;

UCLASS()
class IKUN_API AIkunChrBase : public ACharacter, public IAbilitySystemInterface {
	GENERATED_BODY()
public:
	AIkunChrBase();
	virtual void BeginPlay() override;
	virtual void Tick(float DeltaTime) override;
	virtual void SetupPlayerInputComponent(class UInputComponent* PlayerInputComponent) override;
	UFUNCTION(BlueprintCallable)
	virtual UAbilitySystemComponent* GetAbilitySystemComponent() const override;

protected:
	UPROPERTY(VisibleAnywhere, BlueprintReadWrite, Category = "GAS")
	UIkunAttrSet* AttrSet;
	UPROPERTY(VisibleAnywhere, BlueprintReadWrite, Category = "GAS")
	UIkunASC* ASC;
};
