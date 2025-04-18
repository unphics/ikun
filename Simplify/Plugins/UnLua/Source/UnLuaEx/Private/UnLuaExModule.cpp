#include "UnLuaExModule.h"
#include "Framework/Commands/Commands.h"
#include "UnLua.h"
#include "lua.hpp"
#include "UnLuaLegacy.h"
#include "UnLuaDelegates.h"
#include "UnLuaPrivate.h"

void OnLuaStateCreated(lua_State* L) {
	if (L) {
		FString FileName = FString::Printf(TEXT("%s%s.lua"), *GLuaSrcFullPath, TEXT("Start"));
		if (FPaths::FileExists(FileName)) {
			luaL_dofile(L, TCHAR_TO_ANSI(*FileName));
		}
	}
}

void FUnLuaExModule::StartupModule() {
	FUnLuaDelegates::OnLuaStateCreated.AddStatic(&OnLuaStateCreated);
}
void FUnLuaExModule::ShutdownModule() {}

bool FUnLuaExModule::Exec(UWorld* World, const TCHAR* Cmd, FOutputDevice&) {
	lua_State* L = UnLua::GetState();
	if (L && lua_getglobal(L, "UECmd") == LUA_TFUNCTION) {
		UnLua::FLuaRetValues Ret = UnLua::Call(L, "UECmd", (ANSICHAR*)StringCast<ANSICHAR>(Cmd).Get());
		return Ret.IsValid() && Ret.Num() >= 1 && Ret[0].Value<bool>();
	}
	return false;
}

IMPLEMENT_MODULE(FUnLuaExModule, UnLuaEx)