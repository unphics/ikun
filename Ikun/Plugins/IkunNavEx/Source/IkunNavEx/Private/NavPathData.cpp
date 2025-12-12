/**
 * -----------------------------------------------------------------------------
 *  File        : NavPathData.cpp
 *  Author      : zhengyanshuai
 *  Date        : Wed Dec 10 2025 22:54:33 GMT+0800 (中国标准时间)
 *  Description : 
 *  License     : MIT License
 * -----------------------------------------------------------------------------
 *  Copyright (c) 2025 zhengyanshuai
 * -----------------------------------------------------------------------------
 */

#include "NavPathData.h"

#include "NavigationSystem.h"
#include "GameFramework/Character.h"
#include "Kismet/KismetSystemLibrary.h"

UNavPathData* UNavPathData::FindPathAsync(ACharacter* InChr, FVector InStart, FVector InEnd) {
	if (!InChr || !UKismetSystemLibrary::IsValid(InChr)) {
		return nullptr;
	}
	
	UWorld* world = GEngine->GetWorldFromContextObject(InChr, EGetWorldErrorMode::LogAndReturnNull);
	if (!world) {
		return nullptr;
	}

	UNavigationSystemV1* v1 = UNavigationSystemV1::GetNavigationSystem(world);

	ANavigationData* navData = v1->GetNavDataForProps(InChr->GetNavAgentPropertiesRef(), InStart);
	// ANavigationData* navData = v1->GetDefaultNavDataInstance();
	
	FPathFindingQuery query(InChr, *navData, InStart, InEnd);

	UNavPathData* data = NewObject<UNavPathData>();
	FNavPathQueryDelegate delegate;
	delegate.BindUObject(data, &UNavPathData::OnPathFound);

	data->_NavSys = v1;
	data->_PathQueryId = v1->FindPathAsync(InChr->GetNavAgentPropertiesRef(), query, delegate, EPathFindingMode::Regular);
	return nullptr;
}

void UNavPathData::ClearPathData() {
	this->_NavPoints.Empty();
	this->_CurSegIdx = 1;
	this->_PathQueryId = -1;
}

void UNavPathData::AdvanceSeg() {
	this->_CurSegIdx++;
}

bool UNavPathData::IsPathValid() const {
	return this->_NavPoints.IsValidIndex(this->_CurSegIdx);
}

bool UNavPathData::IsPathFinsihed() const {
	int num = this->_NavPoints.Num();
	return this->_CurSegIdx >= num;
}

FVector UNavPathData::GetCurSegEnd() const {
	if (this->_NavPoints.IsValidIndex(this->_CurSegIdx)) {
		return this->_NavPoints[this->_CurSegIdx];
	}
	return FVector::ZeroVector;
}

bool UNavPathData::IsFinding() const {
	return this->_PathQueryId >= 0;
}

void UNavPathData::CancelFinding() {
	UNavigationSystemV1* v1 = this->_NavSys.Get();
	if (v1 && UKismetSystemLibrary::IsValid(v1) && this->_PathQueryId >= 0) {
		v1->AbortAsyncFindPathRequest(this->_PathQueryId);
	}
}

void UNavPathData::BeginDestroy() {
	UObject::BeginDestroy();
	if (this->IsFinding()) {
		this->CancelFinding();
	}
}

void UNavPathData::OnPathFound(uint32 InPathId, ENavigationQueryResult::Type InResult,
                               TSharedPtr<FNavigationPath> InNavPath) {
	if (this->_PathQueryId != InPathId) {
		return;
	}
	const TArray<FNavPathPoint>& points = InNavPath->GetPathPoints();
	for (auto& pt : points) {
		this->_NavPoints.Add(pt.Location);
	}
	this->OnPathFoundEvent.Broadcast(this->_NavPoints);
	this->OnPathFoundEvent.Clear();
	this->_PathQueryId = -1;
}
