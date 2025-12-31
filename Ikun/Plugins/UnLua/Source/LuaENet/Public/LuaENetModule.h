#pragma once


#include "CoreMinimal.h"
#include "lj_obj.h"
#include "Modules/ModuleManager.h"

class FLuaENetModule : public IModuleInterface {
public:
	virtual void StartupModule() override;
	virtual void ShutdownModule() override;
};