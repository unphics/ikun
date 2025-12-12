/**
 * -----------------------------------------------------------------------------
 *  File        : MoveStuckMonitor.cpp
 *  Author      : zhengyanshuai
 *  Date        : Wed Dec 10 2025 22:54:33 GMT+0800 (中国标准时间)
 *  Description : 
 *  License     : MIT License
 * -----------------------------------------------------------------------------
 *  Copyright (c) 2025 zhengyanshuai
 * -----------------------------------------------------------------------------
 */

#include "MoveStuckMonitor.h"

#include "Kismet/KismetMathLibrary.h"

UMoveStuckMonitor* UMoveStuckMonitor::CreateMonitor(float MaxStuckTime, const FVector& ChrAgentLoc) {
	UMoveStuckMonitor* monitor = NewObject<UMoveStuckMonitor>();
	monitor->_MaxStuckTime = MaxStuckTime;
	monitor->_MoveStuckLoc = ChrAgentLoc;
	monitor->_CurStuckTime = 0;
	return monitor;
}

bool UMoveStuckMonitor::TickMonitor(float DeltaTime, const FVector& ChrAgentLoc) {
	this->_CurStuckTime += DeltaTime;
	if (UKismetMathLibrary::EqualEqual_VectorVector(this->_MoveStuckLoc, ChrAgentLoc), 10) {
		if (this->_CurStuckTime > this->_MaxStuckTime) {
			return true;
		}
	} else {
		this->_CurStuckTime = 0;
		this->_MoveStuckLoc = ChrAgentLoc;
	}
	return false;
}
