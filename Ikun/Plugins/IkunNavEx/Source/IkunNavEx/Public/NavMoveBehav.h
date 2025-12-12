/**
* -----------------------------------------------------------------------------
 *  File        : NavMoveBehav.h
 *  Author      : zhengyanshuai
 *  Date        : Thu Dec 11 2025 22:18:27 GMT+0800 (中国标准时间)
 *  Description : 
 *  License     : MIT License
 * -----------------------------------------------------------------------------
 *  Copyright (c) 2025 zhengyanshuai
 * -----------------------------------------------------------------------------
 */
#pragma once

#include "CoreMinimal.h"
#include "Object.h"
#include "NavMoveBehav.generated.h"

class ACharacter;

/**
 * 
 */
UCLASS()
class IKUNNAVEX_API UNavMoveBehav : public UObject {
	GENERATED_BODY()
public:
	UNavMoveBehav(ACharacter* InOwnerChr);
private:
	ACharacter* _OwnerChr;
};
