#include "Ability/GameplayAbilityBase.h"

#include "GameplayTask.h"
#include "Abilities/Async/AbilityAsync.h"

UGameplayAbilityBase::UGameplayAbilityBase(const FObjectInitializer& ObjectInitializer): Super(ObjectInitializer) {}

void UGameplayAbilityBase::EndAbility(const FGameplayAbilitySpecHandle Handle, const FGameplayAbilityActorInfo* ActorInfo, const FGameplayAbilityActivationInfo ActivationInfo, bool bReplicateEndAbility, bool bWasCancelled) {
	for (auto& task: this->RefTasks) {
		task.EndTask();
	}
	this->RefTasks.Empty();
	for (auto& async: this->RefAsyncs) {
		async.EndAction();
	}
	this->RefAsyncs.Empty();
	this->OnAbilityEndEvent.Broadcast(bWasCancelled);
	this->OnAbilityEndEvent.Clear();
	Super::EndAbility(Handle, ActorInfo, ActivationInfo, bReplicateEndAbility, bWasCancelled);
}
