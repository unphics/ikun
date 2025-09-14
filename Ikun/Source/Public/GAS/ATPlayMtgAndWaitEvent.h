// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
#include "Abilities/Tasks/AbilityTask.h"
#include "ATPlayMtgAndWaitEvent.generated.h"

class UAbilitySystemComponent;

/**使用的委托类型，如果来自蒙太奇回调，EventTag和Payload可能为空*/
DECLARE_DYNAMIC_MULTICAST_DELEGATE_TwoParams(FATPlayMtgAndWaitEventDelegate, FGameplayTag, EventTag, FGameplayEventData, EventData);

/**
 * 此任务将PlayMontageAndWait和WaitForEvent合并为一个任务，因此您可以等待多种类型的激活，例如近战组合
 * 这些代码的大部分都是从这两个能力任务中的一个任务中复制的
 * 在创建特定于游戏的任务时，这是一个很好的任务示例
 * 预计每个游戏都会有一组特定于游戏的任务来做他们想做的事情
 */
UCLASS()
class IKUN_API UATPlayMtgAndWaitEvent : public UAbilityTask {
	GENERATED_BODY()
public:
	UATPlayMtgAndWaitEvent(const FObjectInitializer& ObjectInitializer);
	/**
	 * 这个任务的蓝图节点，PlayMontageAndWaitForEvent，有一些来自自动调用Activate（）的插件的黑魔法
	 * 在K2Node_LatentAbilityCall内部，如AbilityTask.h中所述。用C++编写的能力逻辑可能需要手动调用Activate（）本身。
	 */
	virtual void Activate() override;
	virtual void ExternalCancel() override;
	virtual FString GetDebugString() const override;
	virtual void OnDestroy(bool AbilityEnded) override;
	/**
	* 播放蒙太奇，然后等待它结束。如果发生与EventTags匹配的游戏事件（或EventTags为空），EventReceived代理将使用标签和事件数据进行激发。
	* 如果StopWhenAbilityEnds为真，则如果该能力正常结束，则此蒙太奇将中止。当该功能被明确取消时，它总是被停止。
	* 在正常执行时，当蒙太奇混合时调用OnBlendOut，而当它完全播放完毕时调用OnCompleted
	* 如果另一个蒙太奇覆盖了它，则调用OnInterrupted，如果取消了能力或任务，则调用On cancelled
	* @param TaskInstanceName 设置为覆盖此任务的名称，以便以后查询
	* @param MontageToPlay 要在角色上播放的蒙太奇	
	* @param EventTags 任何与此标签匹配的游戏事件都将激活EventReceived回调。如果为空，则所有事件都将触发回调	
	* @param Rate 更改以更快或更慢的速度播放蒙太奇	
	* @param bStopWhenAbilityEnds 如果为true，如果技能正常结束，则此蒙太奇将中止。当功能被明确取消时，它总是停止	
	* @param AnimRootMotionTranslationScale 更改以修改根运动的大小，或设置为0以完全阻止它	
	*/
	UFUNCTION(BlueprintCallable, Category = "Ability|Task", meta = (HidePin = "OwningAbility", DefaultToSelf = "OwningAbility", BlueprintInternalUseOnly = "TRUE"))
	static UATPlayMtgAndWaitEvent* PlayMtgAndWaitEvent(
		UGameplayAbility* OwningAbility,
		FName TaskInstanceName,
		UAnimMontage* MontageToPlay,
		FGameplayTagContainer EventTags,
		float Rate = 1.f,
		FName StartSection = NAME_None,
		bool bStopWhenAbilityEnds = true,
		float AnimRootMotionTranslationScale = 1.f);
private:
	/**检查该能力是否正在播放蒙太奇并停止该蒙太奇，如果蒙太奇被停止，则返回true，如果没有，则返回false*/
	bool StopPlayingMontage();
	void OnMontageBlendingOut(UAnimMontage* Montage, bool bInterrupted);
	void OnAbilityCancelled();
	void OnMontageEnded(UAnimMontage* Montage, bool bInterrupted);
	void OnGameplayEvent(FGameplayTag EventTag, const FGameplayEventData* Payload);
	UAbilitySystemComponent* GetTargetASC();
public:
	/**蒙太奇完全播放完了*/
	UPROPERTY(BlueprintAssignable)
	FATPlayMtgAndWaitEventDelegate OnCompleted;
	/**蒙太奇开始融合*/
	UPROPERTY(BlueprintAssignable)
	FATPlayMtgAndWaitEventDelegate OnBlendOut;
	/**蒙太奇被打断了*/
	UPROPERTY(BlueprintAssignable)
	FATPlayMtgAndWaitEventDelegate OnInterrupted;
	/**该能力任务被另一个能力明确取消*/
	UPROPERTY(BlueprintAssignable)
	FATPlayMtgAndWaitEventDelegate OnCancelled;
	/**触发游戏的事件之一发生了*/
	UPROPERTY(BlueprintAssignable)
	FATPlayMtgAndWaitEventDelegate EventReceived;
private:
	/**正在播放的蒙太奇*/
	UPROPERTY()
	UAnimMontage* MontageToPlay;
	/**与游戏事件匹配的标签列表*/
	UPROPERTY()
	FGameplayTagContainer EventTags;
	/**播放速率*/
	UPROPERTY()
	float Rate;
	/**开始蒙太奇的部分*/
	UPROPERTY()
	FName StartSection;
	/**修改根部运动的应用方式*/
	UPROPERTY()
	float AnimRootMotionTranslationScale;
	/**相反，如果能力结束，蒙太奇应该中止*/
	UPROPERTY()
	bool bStopWhenAbilityEnds;
	
	FOnMontageBlendingOutStarted BlendingOutDelegate;
	FOnMontageEnded MontageEndedDelegate;
	FDelegateHandle CancelledHandle;
	FDelegateHandle EventHandle;	
};
