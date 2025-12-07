// Fill out your copyright notice in the Description page of Project Settings.


#include "NavPathFinding.h"

#include "NavigationSystem.h"
#include "GameFramework/Character.h"
#include "Kismet/KismetSystemLibrary.h"

UNavPathFinding::UNavPathFinding() {
	
}

UNavPathFinding* UNavPathFinding::FindPathAsync(ACharacter* InChr, FVector InStart, FVector InEnd) {
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

	UNavPathFinding* finding = NewObject<UNavPathFinding>();
	FNavPathQueryDelegate delegate;
	delegate.BindUObject(finding, &UNavPathFinding::OnPathComplated);

	finding->_NavSys = v1;
	finding->_PathQueryId = v1->FindPathAsync(InChr->GetNavAgentPropertiesRef(), query, delegate, EPathFindingMode::Regular);
	finding->AddToRoot();
	
	return finding;
}

void UNavPathFinding::CancelFind() {
	UNavigationSystemV1* v1 = this->_NavSys.Get();
	if (v1 && UKismetSystemLibrary::IsValid(v1) && this->_PathQueryId > 0) {
		v1->AbortAsyncFindPathRequest(this->_PathQueryId);
	}
	this->RemoveFromRoot();
}

bool UNavPathFinding::IsFindValid() {
	return this->_PathQueryId > 0;
}

void UNavPathFinding::OnPathComplated(uint32 InPathId, ENavigationQueryResult::Type InResult, FNavPathSharedPtr InPath) {
	if (this->_PathQueryId != InPathId) {
		return;
	}

	TArray<FVector> pointLocArr;
	const TArray<FNavPathPoint>& points = InPath->GetPathPoints();
	for (auto& pt : points) {
		pointLocArr.Add(pt.Location);
	}
	this->OnPathFindFinishedEvent.Broadcast(pointLocArr);
	this->OnPathFindFinishedEvent.Clear();
	this->RemoveFromRoot();
	this->_PathQueryId = -1;
}
