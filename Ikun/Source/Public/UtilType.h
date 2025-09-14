#pragma once

#include "CoreMinimal.h"

#include "UtilType.Generated.h"

USTRUCT(BlueprintType)
struct IKUN_API FSpawnParamters {
	GENERATED_USTRUCT_BODY()
public:
	UPROPERTY(EditAnywhere, BlueprintReadWrite)
	FName Name;
	UPROPERTY(EditAnywhere, BlueprintReadWrite)
	AActor* TemplateActor;
	UPROPERTY(EditAnywhere, BlueprintReadWrite)
	AActor* Owner;
	UPROPERTY(EditAnywhere, BlueprintReadWrite)
	APawn* Instigator;
	UPROPERTY(EditAnywhere, BlueprintReadWrite)
	class ULevel* OverrideLevel;
	UPROPERTY(EditAnywhere, BlueprintReadWrite)
	ESpawnActorCollisionHandlingMethod CollisionHandling; 
};
