

using System;
using System.IO;
using UnrealBuildTool;

public class LuaENet : ModuleRules
{
	public LuaENet(ReadOnlyTargetRules Target) : base(Target)
	{
		PCHUsage = PCHUsageMode.UseExplicitOrSharedPCHs;
		bEnableUndefinedIdentifierWarnings =  false;

		PublicDependencyModuleNames.AddRange(new string[] { "Core", "CoreUObject", "Engine", "Lua", "UnLua" });
		
		string ENetSrcPath = Path.Combine(ModuleDirectory, "Private/enet");
		PublicIncludePaths.Add(ENetSrcPath);
		PublicIncludePaths.Add(Path.Combine(ModuleDirectory, "Public"));
        
        if (Target.Platform == UnrealTargetPlatform.Win64)
		{
			PublicSystemLibraries.Add("ws2_32.lib");
			PublicSystemLibraries.Add("winmm.lib");
			
			PublicDefinitions.Add("_WINSOCK_DEPRECATED_NO_WARNINGS");
            PublicDefinitions.Add("LUA_BUILD_AS_DLL");
        }
		else if (Target.Platform == UnrealTargetPlatform.Linux || Target.Platform == UnrealTargetPlatform.Android)
		{
			// Linux/Android 通常不需要额外库，但需确保支持 getaddrinfo
			PublicDefinitions.Add("HAS_GETADDRINFO=1");
		}
		else if (Target.Platform == UnrealTargetPlatform.IOS || Target.Platform == UnrealTargetPlatform.Mac)
		{
			PublicDefinitions.Add("HAS_GETADDRINFO=1");
			PublicDefinitions.Add("HAS_INET_PTON=1");
			PublicDefinitions.Add("HAS_INET_NTOP=1");
			PublicDefinitions.Add("HAS_MSGHDR_FLAGS=1");
		}
		bRequiresImplementModule = true;
	}
}