#include "TargetData/AbilityTask_WaitTargetDataBase.h"

UAbilityTask_WaitTargetDataBase* UAbilityTask_WaitTargetDataBase::WaitTargetDataUseCustomActor(UGameplayAbility * OwningAbility, FName TaskInstanceName, TEnumAsByte<EGameplayTargetingConfirmation::Type> ConfirmationType, AGameplayAbilityTargetActor * InTargetActor) {
	UAbilityTask_WaitTargetDataBase* MyObj = NewAbilityTask<UAbilityTask_WaitTargetDataBase>(OwningAbility, TaskInstanceName);		//Register for task list here, providing a given FName as a key
	MyObj->TargetClass = nullptr;
	MyObj->TargetActor = InTargetActor;
	MyObj->ConfirmationType = ConfirmationType;
	return MyObj;
}

void UAbilityTask_WaitTargetDataBase::OnDestroy(bool AbilityEnded) {
	UAbilityTask::OnDestroy(AbilityEnded);
}
