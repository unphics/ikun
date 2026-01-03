#include "ENetSubsystem.h"

#include "UnLuaModule.h"
#include "UnLua.h"

void UENetSubsystem::Initialize(FSubsystemCollectionBase& Collection) {
	Super::Initialize(Collection);
	this->TickHandle = FTSTicker::GetCoreTicker().AddTicker(FTickerDelegate::CreateUObject(this, &UENetSubsystem::OnNetTick), this->TickDelay);
}

void UENetSubsystem::Deinitialize() {
	if (this->TickHandle.IsValid()) {
		FTSTicker::GetCoreTicker().RemoveTicker(this->TickHandle);
		this->TickHandle.Reset();
	}
	Super::Deinitialize();
}

bool UENetSubsystem::OnNetTick(float DeltaTime) {
	if (lua_State* L = UnLua::GetState()) {
		if (lua_getglobal(L, "ENetTick") == LUA_TFUNCTION) {
			UnLua::Call(L, "ENetTick", DeltaTime, this->GetWorld());
		}
	}
	return true;
}

#include <chrono>

extern "C" {
	__declspec(dllexport) int64_t GetUnixTimestampMS() {
		auto now = std::chrono::system_clock::now();
		auto ms = std::chrono::duration_cast<std::chrono::milliseconds>(now.time_since_epoch()).count();
		return (int64_t)ms;
	}
}