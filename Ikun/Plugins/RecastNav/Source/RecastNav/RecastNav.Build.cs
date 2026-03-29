// Copyright Epic Games, Inc. All Rights Reserved.

using UnrealBuildTool;

public class RecastNav : ModuleRules
{
	public RecastNav(ReadOnlyTargetRules Target) : base(Target)
	{
		PCHUsage = ModuleRules.PCHUsageMode.UseExplicitOrSharedPCHs;
		
		PublicIncludePaths.AddRange(new string[] {} );
				
		
		PrivateIncludePaths.AddRange(new string[] {} );
			
		
		PublicDependencyModuleNames.AddRange(new string[] {
				"Core",
				"NavigationSystem",
				"NavMesh",
				"ProceduralMeshComponent"
			});
			
		
		PrivateDependencyModuleNames.AddRange(new string[] {
				"CoreUObject",
				"Engine",
				"Slate",
				"SlateCore",
                "NavMesh",
                "NavigationSystem",
                "ProceduralMeshComponent"
            });
		
		DynamicallyLoadedModuleNames.AddRange(new string[] {} );
	}
}
