// Copyright Epic Games, Inc. All Rights Reserved.

#include "IkunGameMode.h"
#include "IkunCharacter.h"
#include "UObject/ConstructorHelpers.h"

AIkunGameMode::AIkunGameMode()
{
	// set default pawn class to our Blueprinted character
	static ConstructorHelpers::FClassFinder<APawn> PlayerPawnBPClass(TEXT("/Game/ThirdPerson/Blueprints/BP_ThirdPersonCharacter"));
	if (PlayerPawnBPClass.Class != NULL)
	{
		DefaultPawnClass = PlayerPawnBPClass.Class;
	}
}
