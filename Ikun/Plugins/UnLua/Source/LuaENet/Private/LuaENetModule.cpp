#include "LuaENetModule.h"

#include "UnLuaDelegates.h"
#include "UnLuaModule.h"

extern "C" {
	#include "lua.h"
	#include "lualib.h"
	#include "lauxlib.h"
	int luaopen_enet(lua_State* L);
}


void OnLuaStateCreated(lua_State* L) {
	RegisterCustomLuaModule(L, "enet", luaopen_enet);
}

void FLuaENetModule::StartupModule() {
	IModuleInterface::StartupModule();

	FUnLuaDelegates::OnLuaStateCreated.AddStatic(&OnLuaStateCreated);
	if (IUnLuaModule::Get().GetEnv()) {
		if (lua_State* L = IUnLuaModule::Get().GetEnv()->GetMainState()) {
			UE_LOG(LogTemp, Log, TEXT("FUnLuaExModule: LuaState already exists, executing manually."));
			OnLuaStateCreated(L);
		}
	}
}

void FLuaENetModule::ShutdownModule() {
	IModuleInterface::ShutdownModule();
    FUnLuaDelegates::OnLuaStateCreated.RemoveAll(this);
}

IMPLEMENT_MODULE(FLuaENetModule, LuaENet)
