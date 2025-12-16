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
#include "DrawDebugHelpers.h"

UNavSteering::UNavSteering() {
	
}

bool UNavSteering::TryMoveToActor(ACharacter* InOwnerChr, AActor* InTargetActor, float InAcceptRadius) {
	if (!UKismetSystemLibrary::IsValid(InOwnerChr)) {
		return false;
	}
	if (!UKismetSystemLibrary::IsValid(InTargetActor)) {
		return false;
	}
	// 检查目标有效
	FVector fixedLoc;
	bool bTargetReachable = UNavigationSystemV1::K2_ProjectPointToNavigation(InOwnerChr, InTargetActor->K2_GetActorLocation(), fixedLoc,nullptr, nullptr, FVector::ZeroVector);
	if (!bTargetReachable) {
		return false;
	}
	// todo 检查是否已经可以判断抵达
	
	this->OwnerChr = InOwnerChr;
	this->_bIsActorTarget = true;
	this->GoalActor = InTargetActor;
	this->_CachedGoalLoc = fixedLoc;
	this->AcceptRadius = InAcceptRadius;
	FVector ownerAgentLoc = this->OwnerChr->GetNavAgentLocation();
	// 如果目标不在导航网格内, 就在可接受的范围内尝试找一个最近的NavMesh点
	this->NavPathData = UNavPathData::FindPathAsync(this->OwnerChr, ownerAgentLoc, this->_CachedGoalLoc);
	if (!this->NavPathData) {
		return nullptr;
	}
	this->NavPathData->OnPathFoundEvent.AddDynamic(this, &UNavSteering::_OnPathFound_First);
	return true;
}

bool UNavSteering::TryMoveToLoc(ACharacter* InOwnerChr, FVector InTargetLoc, float InAcceptRadius) {
	if (!UKismetSystemLibrary::IsValid(InOwnerChr)) {
		return false;
	}
	if (InTargetLoc.IsNearlyZero(0.1)) {
		return false;
	}
	// 检查目标有效
	FVector fixedLoc;
	bool bTargetReachable = UNavigationSystemV1::K2_ProjectPointToNavigation(InOwnerChr, InTargetLoc, fixedLoc,nullptr, nullptr, FVector::ZeroVector);
	if (!bTargetReachable) {
		return false;
	}
	// todo 检查是否已经可以判断抵达
	
	this->OwnerChr = InOwnerChr;
	this->_bIsActorTarget = false;
	this->GoalLocation = InTargetLoc;
	this->_CachedGoalLoc = fixedLoc;
	this->AcceptRadius = InAcceptRadius;
	FVector ownerAgentLoc = this->OwnerChr->GetNavAgentLocation();
	// 如果目标不在导航网格内, 就在可接受的范围内尝试找一个最近的NavMesh点
	this->NavPathData = UNavPathData::FindPathAsync(this->OwnerChr, ownerAgentLoc, this->_CachedGoalLoc);
	if (!this->NavPathData) {
		return false;
	}
	this->NavPathData->OnPathFoundEvent.AddDynamic(this, &UNavSteering::_OnPathFound_First);
	return true;
}

void UNavSteering::CancelMove() {
	this->OnNavFinishedEvent.Broadcast(ENavSteerResult::Cancelled);
	if (this->OwnerChr && this->OwnerChr->GetController()) {
		this->OwnerChr->GetController()->StopMovement();
	}
	this->SteerEnd();
}

void UNavSteering::_OnPathFound_First(const TArray<FVector>& InPathPoints, bool bSuccess) {
	if (!this->NavPathData->IsPathValid()) {
		FVector ownerAgentLoc = this->OwnerChr->GetNavAgentLocation();
		FVector nearNavPoint;
		FVector QueryExtent(200, 200, 200);
		bool bOwnerMovable = UNavigationSystemV1::K2_ProjectPointToNavigation(this->OwnerChr->GetWorld(), ownerAgentLoc, nearNavPoint, nullptr, nullptr, QueryExtent);
		if (bOwnerMovable) {
			this->NavPathData = UNavPathData::FindPathAsync(this->OwnerChr, nearNavPoint, this->_CachedGoalLoc);
			this->NavPathData->SetFirstPoint(ownerAgentLoc);
			this->NavPathData->OnPathFoundEvent.AddDynamic(this, &UNavSteering::_OnPathFound_Second);
		} else {
			this->OnNavFinishedEvent.Broadcast(ENavSteerResult::Stuck);
			this->SteerEnd();
		}
	} else {
		this->SteerBegin();
	}
}

void UNavSteering::_OnPathFound_Second(const TArray<FVector>& InPathPoints, bool bSuccess) {
	this->SteerBegin();
}

void UNavSteering::SteerBegin() {
	this->_CurPathRefreshTimeCount = 0.0f;
	this->MoveStuckDetector = UMoveStuckDetector::CreateDetector(0.8f, this->OwnerChr->GetNavAgentLocation());
	this->_bSteeringActive = true;
}

void UNavSteering::SteerEnd() {
	this->NavPathData = nullptr;
	this->MoveStuckDetector = nullptr;
	this->GoalActor = nullptr;
	this->_bSteeringActive = false;
	this->OnNavFinishedEvent.Clear();
}

bool UNavSteering::IsAllowedToTick() const {
	if (this->IsTemplate()) {
		return false;
	}
	return this->_bSteeringActive;
}

void UNavSteering::Tick(float InDeltaTime) {
#if WITH_EDITOR
	if (this->bShowDebugLines) {
		this->DrawDebugPath();
	}
#endif
	if (!UKismetSystemLibrary::IsValid(this->NavPathData)) {
		UE_LOG(LogTemp, Error, TEXT("SteerTick: NavPathData is invalid!"));
		this->OnNavFinishedEvent.Broadcast(ENavSteerResult::Lost);
		this->SteerEnd();
		return;
	}
	
	// 判断最后一段抵达
	if (this->NavPathData->IsPathFinsihed()) {
		this->OnNavFinishedEvent.Broadcast(ENavSteerResult::Success);
		this->SteerEnd();
		return;
	}

	// 判断被阻挡
	FVector agentLoc = this->OwnerChr->GetNavAgentLocation();
	if (this->MoveStuckDetector->TickMonitor(InDeltaTime, agentLoc)) {
		this->OnNavFinishedEvent.Broadcast(ENavSteerResult::Stuck);
		this->SteerEnd();
		return;
	}

	// Actor目标则刷新路径
	bool bIsStabilized = (!this->NavPathData->bHasFirst) || (this->NavPathData->CurSegIdx >= 2);
	if (this->_bIsActorTarget && bIsStabilized) {
		this->_CurPathRefreshTimeCount += InDeltaTime;
		if (this->_CurPathRefreshTimeCount > this->NavPathRefreshInterval && !UKismetSystemLibrary::IsValid(this->_PendingNavData)) {
			this->_CurPathRefreshTimeCount = 0.0f;

			if (!UKismetSystemLibrary::IsValid(this->GoalActor)) {
				this->OnNavFinishedEvent.Broadcast(ENavSteerResult::Lost);
				this->SteerEnd();
				return;
			}

			FVector actorLoc = this->GoalActor->K2_GetActorLocation();
			FVector fixedLoc;
			bool bProjected = UNavigationSystemV1::K2_ProjectPointToNavigation(this->OwnerChr, actorLoc, fixedLoc,nullptr, nullptr, FVector::ZeroVector);
			FVector cachedLast = this->_CachedGoalLoc;
			this->_CachedGoalLoc = bProjected ? fixedLoc : actorLoc;
			if (UKismetMathLibrary::NotEqual_VectorVector(this->_CachedGoalLoc, cachedLast, 0.1)) {
				this->_PendingNavData = UNavPathData::FindPathAsync(this->OwnerChr, this->OwnerChr->GetNavAgentLocation(), this->_CachedGoalLoc);
				if (this->_PendingNavData) {
					this->_PendingNavData->OnPathFoundEvent.AddDynamic(this, &UNavSteering::OnPathRefreshed);
				}	
			}
		}
	}

	// 寻路移动
	FVector dir = this->NavPathData->CalcDirToSegEnd(agentLoc);
	this->OwnerChr->AddMovementInput(dir, 1, true);
	
	// 抵达当前段目标则走下一段
	if (this->HasReached()) {
		this->NavPathData->AdvanceSeg();
	}
}

void UNavSteering::OnPathRefreshed(const TArray<FVector>& InPathPoints, bool bSuccess) {
	if (!UKismetSystemLibrary::IsValid(this->_PendingNavData)) {
		return;
	}
	if (bSuccess && this->_PendingNavData->IsPathValid()) {
		this->NavPathData = this->_PendingNavData;
	} else {
		UE_LOG(LogTemp, Warning, TEXT("Path refresh failed, keep using old path."));
	}
	this->_PendingNavData = nullptr;
}

FVector UNavSteering::GetSteerTargetLoc() const {
	if (this->_bIsActorTarget) {
		return FVector::ZeroVector;
	} else {
		FVector fixedLoc;
		bool bSuccess = UNavigationSystemV1::K2_ProjectPointToNavigation(this->OwnerChr->GetWorld(), this->GoalLocation, fixedLoc,nullptr, nullptr, FVector::ZeroVector);
		if (bSuccess) {
			return fixedLoc;
		} else {
			return this->GoalLocation;
		}
	}
}

bool UNavSteering::HasReached() const {
	float distSq = FVector::DistSquared(this->OwnerChr->GetNavAgentLocation(), this->NavPathData->GetCurSegEnd());
	
	bool bIsLastPoint = this->NavPathData->CurSegIdx >= (this->NavPathData->NavPoints.Num() - 1);

	float threshold = bIsLastPoint ? this->AcceptRadius : 100.0f;
	return distSq < (threshold * threshold);
}

void UNavSteering::DrawDebugPath() {
	if (!this->NavPathData) {
		return;
	}
	UWorld* World = this->OwnerChr->GetWorld();
	if (!World) return;

	const TArray<FVector>& Points = this->NavPathData->NavPoints;
	int32 NumPoints = Points.Num();
	int32 CurIdx = this->NavPathData->CurSegIdx;
	FVector AgentLoc = this->OwnerChr->GetNavAgentLocation();

	FVector ZOffset(0, 0, 50.0f);
	// 1. 画整条路径 (绿色 = 未走完, 灰色 = 已走过)
	for (int32 i = 0; i < NumPoints - 1; ++i) {
		FColor LineColor = (i >= CurIdx - 1) ? FColor::Green : FColor::Silver;
		float Thickness = (i >= CurIdx - 1) ? 3.0f : 1.0f;

		DrawDebugLine(World, Points[i] + ZOffset, Points[i + 1] + ZOffset, LineColor, false, -1.0f, 0, Thickness);

		// 画路点球
		DrawDebugSphere(World, Points[i] + ZOffset, 15.0f, 8, LineColor, false, -1.0f, 0, 1.0f);
	}
	// 画终点 (大红球)
	if (NumPoints > 0) {
		DrawDebugSphere(World, Points.Last() + ZOffset, 30.0f, 12, FColor::Red, false, -1.0f, 0, 2.0f);
	}

	// 2. 画当前移动意图 (这一步最重要，看你的输入对不对)
	if (Points.IsValidIndex(CurIdx)) {
		FVector TargetPt = Points[CurIdx];

		// 黄色箭头：从角色指向当前路点
		DrawDebugDirectionalArrow(World, AgentLoc + ZOffset, TargetPt + ZOffset,
			200.0f, FColor::Yellow, false, -1.0f, 0, 5.0f);

		// 打印距离文本
		float Dist = FVector::Dist(AgentLoc, TargetPt);
		FString DebugText = FString::Printf(TEXT("Idx:%d | Dist:%.1f"), CurIdx, Dist);
		DrawDebugString(World, TargetPt + ZOffset + FVector(0, 0, 50), DebugText, nullptr, FColor::White, 0.0f);
	}
}

void UNavSteering::ResetInternal() {
	if (this->NavPathData && this->NavPathData->IsFinding()) {
		this->NavPathData->CancelFinding();
		this->NavPathData = nullptr;
	}
	if (this->_PendingNavData && this->_PendingNavData->IsFinding()) {
		this->_PendingNavData->CancelFinding();
		this->_PendingNavData = nullptr;
	}
	
	this->SteerEnd();
}
