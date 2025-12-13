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

UNavSteering* UNavSteering::RequestMoveToActor(ACharacter* InOwnerChr, AActor* InTargetActor, float InAcceptRadius) {
	if (!UKismetSystemLibrary::IsValid(InOwnerChr)) {
		return nullptr;
	}
	if (!UKismetSystemLibrary::IsValid(InTargetActor)) {
		return nullptr;
	}
	// 检查目标有效
	FVector fixedLoc;
	bool bTargetReachable = UNavigationSystemV1::K2_ProjectPointToNavigation(InOwnerChr, InTargetActor->K2_GetActorLocation(), fixedLoc,nullptr, nullptr, FVector::ZeroVector);
	if (!bTargetReachable) {
		return nullptr;
	}
	// todo 检查是否已经可以判断抵达
	UNavSteering* steer = NewObject<UNavSteering>();
	steer->_OwnerChr = InOwnerChr;
	steer->_bIsActorTarget = true;
	steer->_TargetActor = InTargetActor;
	steer->CachedTarget = fixedLoc;
	steer->AcceptRadius = InAcceptRadius;
	FVector ownerAgentLoc = steer->_OwnerChr->GetNavAgentLocation();
	// 如果目标不在导航网格内, 就在可接受的范围内尝试找一个最近的NavMesh点
	steer->NavPathData = UNavPathData::FindPathAsync(steer->_OwnerChr, ownerAgentLoc, steer->CachedTarget);
	if (!steer->NavPathData) {
		return nullptr;
	}
	steer->NavPathData->OnPathFoundEvent.AddDynamic(steer, &UNavSteering::_OnPathFound_First);
	return steer;
}

UNavSteering* UNavSteering::RequestMoveToLoc(ACharacter* InOwnerChr, FVector InTargetLoc, float InAcceptRadius) {
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
	steer->_OwnerChr = InOwnerChr;
	steer->_bIsActorTarget = false;
	steer->_TargetLoc = InTargetLoc;
	steer->CachedTarget = fixedLoc;
	steer->AcceptRadius = InAcceptRadius;
	FVector ownerAgentLoc = steer->_OwnerChr->GetNavAgentLocation();
	// 如果目标不在导航网格内, 就在可接受的范围内尝试找一个最近的NavMesh点
	steer->NavPathData = UNavPathData::FindPathAsync(steer->_OwnerChr, ownerAgentLoc, steer->CachedTarget);
	if (!steer->NavPathData) {
		return nullptr;
	}
	steer->NavPathData->OnPathFoundEvent.AddDynamic(steer, &UNavSteering::_OnPathFound_First);
	return steer;
}

void UNavSteering::CancelMove() {
	if (this->NavPathData && this->NavPathData->IsFinding()) {
		this->NavPathData->CancelFinding();
		this->NavPathData = nullptr;
	}
	if (this->PendingNavData && this->PendingNavData->IsFinding()) {
		this->PendingNavData->CancelFinding();
		this->PendingNavData = nullptr;
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
			this->NavPathData->SetFirstPoint(ownerAgentLoc);
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
	this->CurPathRefreshTime = 0.0f;
	this->MoveStuckDetector = UMoveStuckDetector::CreateDetector(0.8f, this->_OwnerChr->GetNavAgentLocation());
	this->_OwnerChr->GetWorld()->GetTimerManager().SetTimer(this->_TimerHandle, this, &UNavSteering::_SteerTick, this->_DeltaTime, true);
}

void UNavSteering::_SteerEnd() {
	this->NavPathData = nullptr;
	this->MoveStuckDetector = nullptr;
	this->_TargetActor = nullptr;
	UKismetSystemLibrary::K2_ClearTimerHandle(this->_OwnerChr, this->_TimerHandle);
}

void UNavSteering::_SteerTick() {
	if (!UKismetSystemLibrary::IsValid(this->NavPathData)) {
		UE_LOG(LogTemp, Error, TEXT("SteerTick: NavPathData is invalid!"));
		this->_SteerEnd();
		this->OnNavFinishedEvent.Broadcast(ENavSteerResult::Lost);
		return;
	}
	
	// 判断最后一段抵达
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

	// todo 走过了FirstPoint
	// todo 判断目标在移动
	this->CurPathRefreshTime += this->_DeltaTime;
	if (this->CurPathRefreshTime > this->NavPathRefreshInterval && !UKismetSystemLibrary::IsValid(this->PendingNavData)) {
		this->CurPathRefreshTime = 0.0f;
		this->UpdateCachedTarget();

		this->PendingNavData = UNavPathData::FindPathAsync(this->_OwnerChr, this->_OwnerChr->GetNavAgentLocation(), this->CachedTarget);
		if (this->PendingNavData) {
			this->PendingNavData->OnPathFoundEvent.AddDynamic(this, &UNavSteering::_OnPathRefreshed);
		}
	}

	// 寻路移动
	FVector dir = this->NavPathData->CalcDirToSegEnd(agentLoc);
	this->_OwnerChr->AddMovementInput(dir, 1, true);
	
	// 抵达当前段目标则走下一段
	if (this->HasReached(10)) {
		this->NavPathData->AdvanceSeg();
	}
}

void UNavSteering::_OnPathRefreshed(const TArray<FVector>& InPathPoints, bool bSuccess) {
	if (!UKismetSystemLibrary::IsValid(this->PendingNavData)) {
		return;
	}
	if (bSuccess && this->PendingNavData->IsPathValid()) {
		this->NavPathData = this->PendingNavData;
	} else {
		UE_LOG(LogTemp, Warning, TEXT("Path refresh failed, keep using old path."));
	}
	this->PendingNavData = nullptr;
}

void UNavSteering::UpdateCachedTarget() {
	if (this->_bIsActorTarget && UKismetSystemLibrary::IsValid(this->_TargetActor)) {
		FVector actorLoc = this->_TargetActor->K2_GetActorLocation();
		FVector fixedLoc;
		bool bProjected = UNavigationSystemV1::K2_ProjectPointToNavigation(this->_OwnerChr, actorLoc, fixedLoc,nullptr, nullptr, FVector::ZeroVector);
		this->CachedTarget = bProjected ? fixedLoc : actorLoc;
	}
}

FVector UNavSteering::GetSteerTargetLoc() const {
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

void UNavSteering::DrawDebugPath() {
	if (!this->NavPathData) {
		return;
	}
	UWorld* World = this->_OwnerChr->GetWorld();
	if (!World) return;

	const TArray<FVector>& Points = this->NavPathData->_NavPoints;
	int32 NumPoints = Points.Num();
	int32 CurIdx = this->NavPathData->_CurSegIdx;
	FVector AgentLoc = this->_OwnerChr->GetNavAgentLocation();

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