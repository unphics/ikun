#include "IkunGISubsys.h"

inline bool UIkunGISubsys::ShouldCreateSubsystem(UObject* Outer) const {
	return Super::ShouldCreateSubsystem(Outer);
}

inline void UIkunGISubsys::Initialize(FSubsystemCollectionBase& Collection) {
	Super::Initialize(Collection);
	// UE_LOG(LogTemp, Warning, TEXT("===== UIkunGISubsys::Initialize() ====="))
}

inline void UIkunGISubsys::Deinitialize() {
	Super::Deinitialize();
	// UE_LOG(LogTemp, Warning, TEXT("===== UIkunGISubsys::Deinitialize() ====="))
}

