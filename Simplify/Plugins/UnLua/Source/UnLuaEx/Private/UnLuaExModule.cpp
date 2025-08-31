#include "UnLuaExModule.h"
#include "Framework/Commands/Commands.h"
#include "UnLua.h"
#include "lua.hpp"
#include "UnLuaLegacy.h"
#include "UnLuaDelegates.h"
#include "UnLuaPrivate.h"

#include "UnLuaLib.h"

static FString GetMessage(lua_State* L)
{
	const auto ArgCount = lua_gettop(L);
	FString Message;
	if (!lua_checkstack(L, ArgCount))
	{
		luaL_error(L, "too many arguments, stack overflow");
		return Message;
	}
	for (int ArgIndex = 1; ArgIndex <= ArgCount; ArgIndex++)
	{
		if (ArgIndex > 1)
			Message += "\t";
		Message += UTF8_TO_TCHAR(luaL_tolstring(L, ArgIndex, NULL));
	}
	return Message;
}

static int IkunLog(lua_State* L)
{
	const auto Msg = GetMessage(L);
	SET_WARN_COLOR(COLOR_PURPLE);
	UE_LOG(LogIkun, Log, TEXT("%s"), *Msg);
	CLEAR_WARN_COLOR();
	return 0;
}

static int IkunWarn(lua_State* L)
{
	const auto Msg = GetMessage(L);
	SET_WARN_COLOR(COLOR_PURPLE);
	UE_LOG(LogIkun, Warning, TEXT("%s"), *Msg);
	CLEAR_WARN_COLOR();
	return 0;
}

static int IkunError(lua_State* L)
{
	const auto Msg = GetMessage(L);
	UE_LOG(LogIkun, Error, TEXT("%s"), *Msg);
	return 0;
}

static constexpr luaL_Reg UnLua_ExFunctions[] = {
	{"IkunLog", IkunLog},
	{"IkunWarn", IkunWarn},
	{"IkunError", IkunError},
	{nullptr, nullptr}
};

void OnLuaStateCreated(lua_State* L) {
	if (L) {
		lua_getglobal(L, LUA_GNAME);
		if (lua_istable(L, -1)) {
			luaL_setfuncs(L, UnLua_ExFunctions, 0);
		}
		lua_pop(L, 1);

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