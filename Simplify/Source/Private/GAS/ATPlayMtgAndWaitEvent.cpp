#include "GAS/ATPlayMtgAndWaitEvent.h"
#include "AbilitySystemGlobals.h"
#include "AbilitySystemComponent.h"
#include "GameFramework/Character.h"

UATPlayMtgAndWaitEvent::UATPlayMtgAndWaitEvent(const FObjectInitializer& ObjectInitializer): Super(ObjectInitializer) {
	this->Rate = 1.0f;
	this->bStopWhenAbilityEnds = true;
}

void UATPlayMtgAndWaitEvent::Activate() {
	Super::Activate();
	if (this->Ability/*creater*/ == nullptr) {
		return;
	}
	bool bPlayedMtg = false;
	if (this->AbilitySystemComponent.IsValid()) {
		const FGameplayAbilityActorInfo* GAActorInfo = this->Ability->GetCurrentActorInfo();
		UAnimInstance* AnimInst = GAActorInfo->GetAnimInstance();
		if (AnimInst != nullptr) {
			EventHandle = this->AbilitySystemComponent->AddGameplayEventTagContainerDelegate(EventTags,
				FGameplayEventTagMulticastDelegate::FDelegate::CreateUObject(this, &UATPlayMtgAndWaitEvent::OnGameplayEvent));
			if (this->AbilitySystemComponent->PlayMontage(this->Ability, this->Ability->GetCurrentActivationInfo(),
				this->MontageToPlay, this->Rate, this->StartSection) > 0.0f) {
				//PlayMtg可能会触发对游戏代码的回调，这可能会扼杀这种能力！如果我们正在等待杀戮，那就早点出发。
				if (this->ShouldBroadcastAbilityTaskDelegates() == false) {
					return;
				}
				this->CancelledHandle = this->Ability->OnGameplayAbilityCancelled.AddUObject(this, &UATPlayMtgAndWaitEvent::OnAbilityCancelled);

				BlendingOutDelegate.BindUObject(this, &UATPlayMtgAndWaitEvent::OnMontageBlendingOut);
				AnimInst->Montage_SetBlendingOutDelegate(BlendingOutDelegate, MontageToPlay);

				ACharacter* Character = Cast<ACharacter>(this->GetAvatarActor());
				if (Character &&(Character->GetLocalRole() == ROLE_Authority ||
					(Character->GetLocalRole() == ROLE_AutonomousProxy && this->Ability->GetNetExecutionPolicy() == EGameplayAbilityNetExecutionPolicy::LocalPredicted))) {
					Character->SetAnimRootMotionTranslationScale(this->AnimRootMotionTranslationScale);
				}
			} else {
				UE_LOG(LogTemp, Warning, TEXT("UATPlayMtgAndWaitEvent call to playmontage failed!"))
			}
			bPlayedMtg = true;
		}
	} else {
		UE_LOG(LogTemp, Warning, TEXT("UATPlayMtgAndWaitEvent called on invalid asc!"))
	}

	if (!bPlayedMtg) {
		UE_LOG(LogTemp, Warning, TEXT("UATPlayMtgAndWaitEvent called in ga %s failed to play mtg %s; task inst name: %s"), *this->Ability.GetName(), *GetNameSafe(this->MontageToPlay), *this->InstanceName.ToString());
		if (this->ShouldBroadcastAbilityTaskDelegates()) {
			// ABILITY_LOG(Display, TEXT("%s: OnCancelled"), *GetName());
			OnCancelled.Broadcast(FGameplayTag(), FGameplayEventData());
		}
	}
	this->SetWaitingOnAvatar();
}

void UATPlayMtgAndWaitEvent::ExternalCancel() {
	//check(this->AbilitySystemComponent);
	this->OnAbilityCancelled();
	Super::ExternalCancel();
}

FString UATPlayMtgAndWaitEvent::GetDebugString() const {
	// Super::GetDebugString();
	UAnimMontage* PlayingMtg = nullptr;
	if (this->Ability) {
		const FGameplayAbilityActorInfo* ActorInfo = this->Ability->GetCurrentActorInfo();
		UAnimInstance* AnimInst = ActorInfo->GetAnimInstance();
		if (AnimInst != nullptr) {
			PlayingMtg = AnimInst->Montage_IsActive(this->MontageToPlay) ? this->MontageToPlay : AnimInst->GetCurrentActiveMontage();
		}
	}
	return FString::Printf(TEXT("PlayMtgAndWaitEvent: MtgToPlay: %s (CurPlaing): %s"), *GetNameSafe(this->MontageToPlay), *GetNameSafe(PlayingMtg));
}

void UATPlayMtgAndWaitEvent::OnDestroy(bool AbilityEnded) {
	//注意：不需要清除蒙太奇结束代理，因为它不是多播，并且将在下一个蒙太奇播放时清除。
	//（如果我们被摧毁，它会检测到这一点，不会采取任何行动）
	//但是，应该清除此委托，因为它是一个多播
	if (this->Ability) {
		this->Ability->OnGameplayAbilityCancelled.Remove(this->CancelledHandle);
		if (AbilityEnded && this->bStopWhenAbilityEnds) {
			this->StopPlayingMontage();
		}
	}
	UAbilitySystemComponent* asc = this->GetTargetASC();
	if (asc) {
		asc->RemoveGameplayEventTagContainerDelegate(this->EventTags, this->EventHandle);
	}
	Super::OnDestroy(AbilityEnded);
}

UATPlayMtgAndWaitEvent* UATPlayMtgAndWaitEvent::PlayMtgAndWaitEvent(UGameplayAbility* OwningAbility,
	FName TaskInstanceName, UAnimMontage* MontageToPlay, FGameplayTagContainer EventTags, float Rate,
	FName StartSection, bool bStopWhenAbilityEnds, float AnimRootMotionTranslationScale) {
	UAbilitySystemGlobals::NonShipping_ApplyGlobalAbilityScaler_Rate(Rate);

	UATPlayMtgAndWaitEvent* at = NewAbilityTask<UATPlayMtgAndWaitEvent>(OwningAbility, TaskInstanceName);
	at->MontageToPlay = MontageToPlay;
	at->EventTags = EventTags;
	at->Rate = Rate;
	at->StartSection = StartSection;
	at->bStopWhenAbilityEnds = bStopWhenAbilityEnds;
	at->AnimRootMotionTranslationScale = AnimRootMotionTranslationScale;

	return at;
}

bool UATPlayMtgAndWaitEvent::StopPlayingMontage() {
	const FGameplayAbilityActorInfo* ActorInfo = this->Ability->GetCurrentActorInfo();
	if (!ActorInfo) {
		return false;
	}
	UAnimInstance* animInst = ActorInfo->GetAnimInstance();
	if (animInst == nullptr) {
		return false;
	}
	//检查蒙太奇是否仍在播放
	//这种能力会被中断，在这种情况下，我们应该自动停止蒙太奇
	if (this->AbilitySystemComponent != nullptr && this->Ability) {
		if (this->AbilitySystemComponent->GetAnimatingAbility() == this->Ability &&
			this->AbilitySystemComponent->GetCurrentMontage() == this->MontageToPlay) {
			//取消绑定代理，以免他们也被呼叫
			FAnimMontageInstance* mtgInst = animInst->GetActiveInstanceForMontage(this->MontageToPlay);
			if (mtgInst) {
				mtgInst->OnMontageBlendingOutStarted.Unbind();
				mtgInst->OnMontageEnded.Unbind();
			}
			this->AbilitySystemComponent->CurrentMontageStop();
			return true;
		}
	}
	return false;
}
void UATPlayMtgAndWaitEvent::OnMontageBlendingOut(UAnimMontage* Montage, bool bInterrupted) {
	if (this->Ability && this->Ability->GetCurrentMontage() == this->MontageToPlay) {
		if (Montage == this->MontageToPlay) {
			this->AbilitySystemComponent->ClearAnimatingAbility(this->Ability);
			//重置动画根运动平移比例
			ACharacter* Character = Cast<ACharacter>(this->GetAvatarActor());
			if (Character && Character->GetLocalRole() == ROLE_Authority || (Character->GetLocalRole() == ROLE_AutonomousProxy
				&& this->Ability->GetNetExecutionPolicy() == EGameplayAbilityNetExecutionPolicy::LocalPredicted)) {
				Character->SetAnimRootMotionTranslationScale(1.0f);
			}
		}
	}
	if (bInterrupted) {
		if (this->ShouldBroadcastAbilityTaskDelegates()) {
			OnInterrupted.Broadcast(FGameplayTag(), FGameplayEventData());
		}
	} else {
		if (this->ShouldBroadcastAbilityTaskDelegates()) {
			OnBlendOut.Broadcast(FGameplayTag(), FGameplayEventData());
		}
	}
}
void UATPlayMtgAndWaitEvent::OnAbilityCancelled() {
	//TODO:将此修复程序合并回引擎，它调用了错误的回调
	if (this->StopPlayingMontage()) {
		//让BP也处理中断
		if (this->ShouldBroadcastAbilityTaskDelegates()) {
			OnCancelled.Broadcast(FGameplayTag(), FGameplayEventData());
		}
	}
}
void UATPlayMtgAndWaitEvent::OnMontageEnded(UAnimMontage* Montage, bool bInterrupted) {
	if (!bInterrupted) {
		if (this->ShouldBroadcastAbilityTaskDelegates()) {
			OnCompleted.Broadcast(FGameplayTag(), FGameplayEventData());
		}
	}
	this->EndTask();
}
void UATPlayMtgAndWaitEvent::OnGameplayEvent(FGameplayTag EventTag, const FGameplayEventData* Payload) {
	if (this->ShouldBroadcastAbilityTaskDelegates()) {
		FGameplayEventData tempData = *Payload;
		tempData.EventTag = EventTag;
		EventReceived.Broadcast(EventTag, tempData);
	}
}

UAbilitySystemComponent* UATPlayMtgAndWaitEvent::GetTargetASC() {
	return Cast<UAbilitySystemComponent>(this->AbilitySystemComponent);
}
