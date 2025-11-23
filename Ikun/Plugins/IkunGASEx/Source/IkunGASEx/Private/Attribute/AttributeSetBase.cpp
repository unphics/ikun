// Fill out your copyright notice in the Description page of Project Settings.


#include "Attribute/AttributeSetBase.h"

void UAttributeSetBase::PreAttributeChange(const FGameplayAttribute& Attribute, float& NewValue) {
	Super::PreAttributeChange(Attribute, NewValue);
	this->ReceivePreAttributeChange(Attribute, NewValue);
}

void UAttributeSetBase::PostAttributeChange(const FGameplayAttribute& Attribute, float OldValue, float NewValue) {
	Super::PostAttributeChange(Attribute, OldValue, NewValue);
	this->ReceivePostAttributeChange(Attribute, OldValue, NewValue);
}
