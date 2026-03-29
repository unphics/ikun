// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
#include "GameFramework/Actor.h"
#include "ProceduralMeshComponent.h"
#include "RecastVoxel.generated.h"

struct rcHeightfield;

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
	UFUNCTION(BlueprintCallable, CallInEditor)
	void LoadNavConfig();
	UPROPERTY(BlueprintReadWrite, EditAnywhere)
	float CellSize;
	UPROPERTY(BlueprintReadWrite, EditAnywhere)
	float CellHeight;
	
	//recaster
	UFUNCTION(BlueprintCallable, CallInEditor) 
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
