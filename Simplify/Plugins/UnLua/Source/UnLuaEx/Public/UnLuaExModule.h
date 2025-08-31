#pragma once

#include "CoreMinimal.h"
#include "Modules/ModuleManager.h"

DECLARE_LOG_CATEGORY_EXTERN(LogIkun, Log, All)
DEFINE_LOG_CATEGORY(LogIkun)

class FUnLuaExModule : public IModuleInterface, private FSelfRegisteringExec {
public:
	virtual void StartupModule() override;
	virtual void ShutdownModule() override;
	virtual bool Exec(UWorld* World, const TCHAR* Cmd, FOutputDevice&) override;
};