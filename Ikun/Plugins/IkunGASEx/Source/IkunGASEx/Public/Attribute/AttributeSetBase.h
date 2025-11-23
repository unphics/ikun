// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
#include "AttributeSet.h"
#include "AttributeSetBase.generated.h"

/**
 * 
 */
UCLASS()
class IKUNGASEX_API UAttributeSetBase : public UAttributeSet {
	GENERATED_BODY()
public:
	virtual void PreAttributeChange(const FGameplayAttribute& Attribute, float& NewValue) override;
	virtual void PostAttributeChange(const FGameplayAttribute& Attribute, float OldValue, float NewValue) override;
	
	UFUNCTION(BlueprintImplementableEvent)
	void ReceivePreAttributeChange(const FGameplayAttribute& Attribute, float& NewValue);
	UFUNCTION(BlueprintImplementableEvent)
	void ReceivePostAttributeChange(const FGameplayAttribute& Attribute, float OldValue, float NewValue);
};
