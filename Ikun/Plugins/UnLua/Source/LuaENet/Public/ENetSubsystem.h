#pragma once

#include "CoreMinimal.h"
#include "Containers/Ticker.h"
#include "ENetSubsystem.generated.h"

UCLASS()
class LUAENET_API UENetSubsystem : public UGameInstanceSubsystem {
	GENERATED_BODY()

	/** override **/
	virtual void Initialize(FSubsystemCollectionBase& Collection) override;
	virtual void Deinitialize() override;
	virtual bool ShouldCreateSubsystem() const { return true; }
	
	/** tick **/
private:
	bool OnNetTick(float DeltaTime);
	FTSTicker::FDelegateHandle TickHandle;
	float TickDelay = 0.033f;
};
