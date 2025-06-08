// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
#include "Abilities/GameplayAbility.h"
#include "IkunGABase.generated.h"

/**
 * 
 */
UCLASS()
class IKUN_API UIkunGABase : public UGameplayAbility {
	GENERATED_BODY()
public:
	// 技能的配置Id
	UPROPERTY(EditDefaultsOnly, BlueprintReadOnly, Category = "IkunAbilitySetting", meta = (ToolTip = "Skill config ident"))
	int AbilityCfgId = 0;
	// 考虑激活的最大距离
	UPROPERTY(EditDefaultsOnly, BlueprintReadOnly, Category = "IkunAbilitySetting", meta = (ToolTip = "Skill min distance that consider to activated"))
	int MaxConsiderDist = 0;
	// 考虑激活的最小距离
	UPROPERTY(EditDefaultsOnly, BlueprintReadOnly, Category = "IkunAbilitySetting", meta = (ToolTip = "Skill min distance that consider to activated"))
	int MinConsiderDist = 0;
	// 可激活的最大距离
	UPROPERTY(EditDefaultsOnly, BlueprintReadOnly, Category = "IkunAbilitySetting", meta = (ToolTip = "Skill max distance that can be activated"))
	int MaxActivatableDist = 0;
	// 可激活的最小距离
	UPROPERTY(EditDefaultsOnly, BlueprintReadOnly, Category = "IkunAbilitySetting", meta = (ToolTip = "Skill min distance that can be activated"))
	int MinActivatableDist = 0;
	// 可激活的方向, 相较于前向
	UPROPERTY(EditDefaultsOnly, BlueprintReadOnly, Category = "IkunAbilitySetting", meta = (ToolTip = "Skill direct that can be activated, compared to forward direction"))
	int YawActivatableDir = 0;
	// 可激活的方向扩展
	UPROPERTY(EditDefaultsOnly, BlueprintReadOnly, Category = "IkunAbilitySetting", meta = (ToolTip = "Skill direct extend that can be activated"))
	int YawActivatableExtend = 0;
	// 技能权重
	UPROPERTY(EditDefaultsOnly, BlueprintReadOnly, Category = "IkunAbilitySetting", meta = (ToolTip = "Skill weight"))
	int SkillWeight = 0;

};
