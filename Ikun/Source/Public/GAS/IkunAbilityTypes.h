
#pragma once

#include "GameplayEffectTypes.h"
#include "IkunAbilityTypes.generated.h"

USTRUCT(BlueprintType) // 蓝图中可用
struct FIkunGameplayEffectContext: public FGameplayEffectContext {
	GENERATED_BODY()
public:
	UPROPERTY(EditAnywhere, BlueprintReadWrite)
	TObjectPtr<UObject> OptionalObject;

	UPROPERTY(EditAnywhere, BlueprintReadWrite)
	TObjectPtr<UObject> OptionalObject2;

	virtual FIkunGameplayEffectContext* Duplicate() const override {
		FIkunGameplayEffectContext * newContext = new FIkunGameplayEffectContext();
		*newContext = *this; // WithCopy设置为true, 就可以通过赋值操作进行拷贝
		if (this->GetHitResult()) {
			newContext->AddHitResult(*this->GetHitResult(), true);
		}
		return newContext;
	}
};

template<>
struct TStructOpsTypeTraits<FIkunGameplayEffectContext> : public TStructOpsTypeTraitsBase2<FIkunGameplayEffectContext>
{
	enum
	{
		WithNExtSerializer = true,
		WithCopy = true
	};
};
