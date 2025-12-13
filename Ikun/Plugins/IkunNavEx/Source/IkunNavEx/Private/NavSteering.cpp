/**
* -----------------------------------------------------------------------------
 *  File        : NavSteering.cpp
 *  Author      : zhengyanshuai
 *  Date        : Thu Dec 11 2025 22:18:27 GMT+0800 (中国标准时间)
 *  Description : 
 *  License     : MIT License
 * -----------------------------------------------------------------------------
 *  Copyright (c) 2025 zhengyanshuai
 * -----------------------------------------------------------------------------
 */
#include "NavSteering.h"

#include "MoveStuckDetector.h"
#include "NavigationSystem.h"
#include "NavPathData.h"
#include "GameFramework/Character.h"
#include "Kismet/KismetMathLibrary.h"
#include "Kismet/KismetSystemLibrary.h"

UNavSteering::UNavSteering() {
	
}

UNavSteering* UNavSteering::RequestMoveToLoc(ACharacter* InOwnerChr, const FVector& InTargetLoc, float InAcceptRadius) {
	if (!UKismetSystemLibrary::IsValid(InOwnerChr)) {
		return nullptr;
	}
	if (InTargetLoc.IsNearlyZero(0.1)) {
		return nullptr;
	}
	// 检查目标有效
	FVector fixedLoc;
	bool bTargetReachable = UNavigationSystemV1::K2_ProjectPointToNavigation(InOwnerChr, InTargetLoc, fixedLoc,nullptr, nullptr, FVector::ZeroVector);
	if (!bTargetReachable) {
		return nullptr;
	}
	// todo 检查是否已经可以判断抵达
	UNavSteering* steer = NewObject<UNavSteering>();
	steer->_bIsActorTarget = false;
	steer->_TargetLoc = InTargetLoc;
	steer->CachedTarget = fixedLoc;
	steer->AcceptRadius = InAcceptRadius;
	FVector ownerAgentLoc = steer->_OwnerChr->GetNavAgentLocation();
	// 如果目标不在导航网格内, 就在可接受的范围内尝试找一个最近的NavMesh点
	steer->NavPathData = UNavPathData::FindPathAsync(steer->_OwnerChr, ownerAgentLoc, steer->CachedTarget);
	steer->NavPathData->OnPathFoundEvent.AddDynamic(steer, &UNavSteering::_OnPathFound_First);
	return steer;
}

void UNavSteering::CancelMove() {
	if (this->NavPathData && this->NavPathData->IsFinding()) {
		this->NavPathData->CancelFinding();
	}
	this->_SteerEnd();
	this->OnNavFinishedEvent.Broadcast(ENavSteerResult::Cancelled);
}

void UNavSteering::_OnPathFound_First(const TArray<FVector>& InPathPoints, bool bSuccess) {
	if (!this->NavPathData->IsPathValid()) {
		FVector ownerAgentLoc = this->_OwnerChr->GetNavAgentLocation();
		FVector nearNavPoint;
		FVector QueryExtent(200, 200, 200);
		bool bOwnerMovable = UNavigationSystemV1::K2_ProjectPointToNavigation(this->_OwnerChr->GetWorld(), ownerAgentLoc, nearNavPoint, nullptr, nullptr, QueryExtent);
		if (bOwnerMovable) {
			this->NavPathData = UNavPathData::FindPathAsync(this->_OwnerChr, nearNavPoint, this->CachedTarget);
			this->NavPathData->AddFirst(ownerAgentLoc);
			this->NavPathData->OnPathFoundEvent.AddDynamic(this, &UNavSteering::_OnPathFound_Second);
		} else {
			this->OnNavFinishedEvent.Broadcast(ENavSteerResult::Stuck);
		}
	} else {
		this->_SteerBegin();
	}
}

void UNavSteering::_OnPathFound_Second(const TArray<FVector>& InPathPoints, bool bSuccess) {
	this->_SteerBegin();
}

void UNavSteering::_SteerBegin() {
	this->MoveStuckDetector = UMoveStuckDetector::CreateDetector(0.8f, this->_OwnerChr->GetNavAgentLocation());
	this->_OwnerChr->GetWorld()->GetTimerManager().SetTimer(this->_TimerHandle, this, &UNavSteering::_SteerTick, this->_DeltaTime, true);
}

void UNavSteering::_SteerEnd() {
	this->NavPathData = nullptr;
	this->MoveStuckDetector = nullptr;
	UKismetSystemLibrary::K2_ClearTimerHandle(this->_OwnerChr, this->_TimerHandle);
}

void UNavSteering::_SteerTick() {
	if (!this->NavPathData || !UKismetSystemLibrary::IsValid(this->NavPathData)) {
		UE_LOG(LogTemp, Error, TEXT("SteerTick: NavPathData is invalid!"));
		this->_SteerEnd();
		this->OnNavFinishedEvent.Broadcast(ENavSteerResult::Lost);
		return;
	}
	
	// 判断跑完了
	if (this->NavPathData->IsPathFinsihed()) {
		this->_SteerEnd();
		this->OnNavFinishedEvent.Broadcast(ENavSteerResult::Success);
		return;
	}

	// 判断被阻挡
	FVector agentLoc = this->_OwnerChr->GetNavAgentLocation();
	if (this->MoveStuckDetector->TickMonitor(this->_DeltaTime,agentLoc)) {
		this->_SteerEnd();
		this->OnNavFinishedEvent.Broadcast(ENavSteerResult::Stuck);
		return;
	}

	// 寻路移动
	FVector dir = this->NavPathData->CalcDirToSegEnd(agentLoc);
	this->_OwnerChr->AddMovementInput(dir, 1, false);
	
	// 抵达当前段目标则走下一段
	if (this->HasReached()) {
		this->NavPathData->AdvanceSeg();
	}
}

const FVector& UNavSteering::GetSteerTargetLoc() const {
	if (this->_bIsActorTarget) {
		return FVector::ZeroVector;
	} else {
		FVector fixedLoc;
		bool bSuccess = UNavigationSystemV1::K2_ProjectPointToNavigation(this->_OwnerChr->GetWorld(), this->_TargetLoc, fixedLoc,nullptr, nullptr, FVector::ZeroVector);
		if (bSuccess) {
			return fixedLoc;
		} else {
			return this->_TargetLoc;
		}
	}
}

bool UNavSteering::HasReached(float RadiusCorr) const {
	float distance = UKismetMathLibrary::Vector_Distance(this->_OwnerChr->GetNavAgentLocation(), this->NavPathData->GetCurSegEnd());
	if (distance < this->AcceptRadius * RadiusCorr) {
		return true;
	}
	return false;
}
