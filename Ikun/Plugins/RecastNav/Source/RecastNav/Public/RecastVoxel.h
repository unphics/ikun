// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
#include "GameFramework/Actor.h"
#include "ProceduralMeshComponent.h"
#include "RecastVoxel.generated.h"

struct rcHeightfield;

USTRUCT(BlueprintType)
struct FTriangle {
	GENERATED_BODY()
	FTriangle(FVector p0, FVector p1, FVector p2) {
		this->Point[0] = p0;
		this->Point[1] = p1;
		this->Point[2] = p2;
	}
	FTriangle() {
		this->Point[0] = FVector::ZeroVector;
		this->Point[1] = FVector::ZeroVector;
		this->Point[2] = FVector::ZeroVector;
	}
	FVector Point[3];
};

UCLASS()
class RECASTNAV_API ARecastVoxel : public AActor {
	GENERATED_BODY()
public:
	ARecastVoxel();
	virtual void BeginPlay() override;
	virtual void Tick(float DeltaTime) override;

	UFUNCTION(BlueprintCallable, CallInEditor)
	void ComputeVoxelOfTargetMesh();
	
	// config
	void LoadNavConfig();
	UPROPERTY(BlueprintReadWrite, EditAnywhere)
	float CellSize;
	UPROPERTY(BlueprintReadWrite, EditAnywhere)
	float CellHeight;
	
	//recaster
	void RasterizeMeshToHeightField();
	UPROPERTY(BlueprintReadWrite, EditAnywhere)
	AActor* TargetActor;
	
	// heightfield
	void CreateNewHeightField(FBox& InBBox);
	rcHeightfield* HeightField;
	
	// ProceduralMesh
	void VisualizeHeightField();
	UProceduralMeshComponent* ProceduralMesh;
	UPROPERTY(EditAnywhere, Category = "NavInsight")
	UMaterial* VolMaterial;
};
