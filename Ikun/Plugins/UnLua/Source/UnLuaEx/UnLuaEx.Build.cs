using UnrealBuildTool;
using System.IO;

public class UnLuaEx: ModuleRules {
    public UnLuaEx(ReadOnlyTargetRules Target): base(Target) {
        PCHUsage = ModuleRules.PCHUsageMode.UseExplicitOrSharedPCHs;

        PublicIncludePaths.AddRange(new string[] {
        });
        PrivateIncludePaths.AddRange(new string[] { 
            "UnLuaEx/Public",
            "UnLuaEx/Private",
            "UnLua/Private",
            "UnLua/Public",
        });
        PublicDependencyModuleNames.AddRange(new string[] { "Core" });
        PrivateDependencyModuleNames.AddRange(new string[] { 
            "CoreUObject",
            "Engine",
            "InputCore",
            "Slate",
            "SlateCore",
            "Projects",
            "UnLua",
            "Lua"
        });
        PublicIncludePaths.Add(Path.Combine(ModuleDirectory, "Private"));
        if (Target.bBuildEditor == true) {
            PrivateDependencyModuleNames.Add("Blutility");
            PrivateDependencyModuleNames.Add("UnrealEd");
            PrivateDependencyModuleNames.Add("UMGEditor");
        }
    }
}