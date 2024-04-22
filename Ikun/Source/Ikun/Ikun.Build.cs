// Copyright Epic Games, Inc. All Rights Reserved.

using UnrealBuildTool;

public class Ikun : ModuleRules
{
	public Ikun(ReadOnlyTargetRules Target) : base(Target)
	{
		PCHUsage = PCHUsageMode.UseExplicitOrSharedPCHs;

		PublicDependencyModuleNames.AddRange(new string[] { "Core", "CoreUObject", "Engine", "InputCore", "HeadMountedDisplay", "EnhancedInput", "GameplayTasks", "Slate", "SlateCore", "GameplayAbilities", "GameplayTags", "UMG"});
	}
}
