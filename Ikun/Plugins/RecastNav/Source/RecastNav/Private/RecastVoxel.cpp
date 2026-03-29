#include "RecastVoxel.h"

#include "NavigationSystem.h"
#include "Kismet/KismetSystemLibrary.h"
#include "ProceduralMeshComponent.h"
#include "NavMesh/RecastNavMesh.h"
#include "Navmesh/RecastNavMeshGenerator.h"
#include "DrawDebugHelpers.h"
#include "Navmesh/Public/Recast/Recast.h"

namespace InsightRecast
{
	struct FRecastGeometry {

		struct FHeader {
			FNavigationRelevantData::FCollisionDataHeader Validation;
			int32_t NumVerts;
			int32_t NumFaces;
			FWalkableSlopeOverride SlopOverride;
			static uint32_t StaticMagicNumber;
		};

		FRecastGeometry(const uint8* InMemory) {
			this->Header = *((FHeader*)InMemory);
			this->Verts = (float*)(InMemory + sizeof(FHeader));
			this->Indices = (int32*)(InMemory + sizeof(FHeader) + (sizeof(float) * this->Header.NumVerts * 3));
		}
		
		FHeader Header;
		float* Verts;
		int32_t* Indices;
	};
}

ARecastVoxel::ARecastVoxel() {
	PrimaryActorTick.bCanEverTick = true;
	
	this->ProceduralMesh = this->CreateDefaultSubobject<UProceduralMeshComponent>("ProceduralMesh");
	this->RootComponent = this->ProceduralMesh;
}

void ARecastVoxel::BeginPlay() {
	Super::BeginPlay();
}

void ARecastVoxel::Tick(float DeltaTime) {
	Super::Tick(DeltaTime);
}

void ARecastVoxel::ComputeVoxelOfTargetMesh() {
	this->LoadNavConfig();
	this->RasterizeMeshToHeightField();
	this->VisualizeHeightField();
}

void ARecastVoxel::LoadNavConfig() {
	const UNavigationSystemV1* v1 = UNavigationSystemV1::GetNavigationSystem(this->GetWorld());
	ANavigationData* navData = v1->GetDefaultNavDataInstance();
	if (navData) {
		ARecastNavMesh* recastNavData = Cast<ARecastNavMesh>(navData);
		this->CellSize = recastNavData->CellSize;
		this->CellHeight = recastNavData->CellHeight;
	}
}

void ARecastVoxel::RasterizeMeshToHeightField() {
	if (!this->TargetActor || !UKismetSystemLibrary::IsValid((this->TargetActor))) {
		return;
	}
	
	// 获取静态网格体
	UStaticMeshComponent* meshComp = Cast<UStaticMeshComponent>(this->TargetActor->GetComponentByClass(UStaticMeshComponent::StaticClass()));
	if (!meshComp) {
		return;
	}
	
	// 几何数据导出
	FNavigationRelevantData navRelevantData(*this->TargetActor); // 存储导航相关的几何信息
	
	FRecastNavMeshGenerator::ExportComponentGeometry(meshComp, navRelevantData); // 将组件的碰撞网格数据导出
	const TNavStatArray<uint8>& rawCollisionCache = navRelevantData.CollisionData; // 包含实际的顶点和索引数据(以字节数组的形式存储)
	if (rawCollisionCache.Num() == 0) {
		return;
	}
	
	// 数据结构转换; 将原始字节数据解析为结构化的几何数据
	InsightRecast::FRecastGeometry collisionCache(rawCollisionCache.GetData());
	
	const int32 numCoords = collisionCache.Header.NumVerts * 3;
	const int32 numIndices = collisionCache.Header.NumFaces * 3;
	
	// 计算包围盒
	FBox bbox = meshComp->GetNavigationBounds();
	bbox = Unreal2RecastBox(bbox);
	
	// 包围盒扩展
	static float padding = 10.0f;
	bbox.Min -= {padding, padding, padding};
	bbox.Max += {padding, padding, padding};
	
	// 创建recast库的上下文对象
	rcContext ctx;
	
	double startStamp = FPlatformTime::Seconds();
	
	// 创建高度场
	this->CreateNewHeightField(bbox);
	
	// 光栅化循环
	for (int i = 0; i < numIndices; i += 3) {
		int32_t idxA = collisionCache.Indices[i];
		int32_t idxB = collisionCache.Indices[i + 1];
		int32_t idxC = collisionCache.Indices[i + 2];
		
		FVector posA (collisionCache.Verts[idxA * 3 + 0], collisionCache.Verts[idxA * 3 + 1], collisionCache.Verts[idxA * 3 + 2]);
		FVector posB (collisionCache.Verts[idxB * 3 + 0], collisionCache.Verts[idxB * 3 + 1], collisionCache.Verts[idxB * 3 + 2]);
		FVector posC (collisionCache.Verts[idxC * 3 + 0], collisionCache.Verts[idxC * 3 + 1], collisionCache.Verts[idxC * 3 + 2]);
		
		rcRasterizeTriangle(&ctx, &posA.X, &posB.X, &posC.X, 0, *this->HeightField); // 将三角形投影到高度场的二维网格上
	}
	
	double endStamp = FPlatformTime::Seconds();
	
}

void ARecastVoxel::CreateNewHeightField(FBox& InBBox) {
	if (this->HeightField) {
		rcFreeHeightField(this->HeightField);
	}
	int HFWidth = 0;
	int HFHeight = 0;
	
	rcCalcGridSize(&InBBox.Min.X, &InBBox.Max.X, this->CellSize, &HFWidth, &HFHeight);
	
	this->HeightField = rcAllocHeightfield();
	rcCreateHeightfield(nullptr, *this->HeightField, HFWidth, HFHeight, &InBBox.Min.X, &InBBox.Max.X, this->CellSize, this->CellHeight);
}

void ARecastVoxel::VisualizeHeightField() {
	// 准备渲染数据结构
	TArray<FVector> verts; // 存储所有顶点坐标
	TArray<int32_t> triangles; // 存储三角形索引
	TArray<FVector> normals; // 存储每个顶点的法线向量
	TArray<FVector2D> uv0; // 存储UV坐标(此处为空
	TArray<FProcMeshTangent> tangents; // 存储切线向量
	TArray<FLinearColor> colors; // 存储顶点颜色信息
	
	FVector pos = this->GetActorLocation();
	
	// 定义绘制单个span的lambda函数; 为每个rcSpan生成一个立方体网格
	auto drawSpan = [&](rcSpan& InSpan, int x, int y) {
		// 绘制逻辑
		
		static float padding = 2.0f;
		
		// 边界计算
		FVector bboxMin(this->HeightField->bmin[0], this->HeightField->bmin[1], this->HeightField->bmin[2]);
		
		bboxMin.X += this->HeightField->cs/*单元格大小*/ * x + padding;
		bboxMin.Z += this->HeightField->cs * y + padding;
		bboxMin.Y += this->HeightField->ch/*单元格高度*/ * (InSpan.data.smin/*span的最小高度*/);
		
		FVector bboxMax(
			bboxMin.X + this->HeightField->cs - padding * 2.0f,
			bboxMin.Z + this->HeightField->cs - padding * 2.0f,
			bboxMin.Y + (InSpan.data.smax - InSpan.data.smin) * this->HeightField->ch
		);
		
		// 坐标系转换; 将recast坐标系转成unreal坐标系; 减去actorPos使网格相对于actor定位
		bboxMin = Recast2UnrealPoint(bboxMin) - pos;
		bboxMax = Recast2UnrealPoint(bboxMax) + pos;
		
		// 立方体顶点生成; 为立方体的6个面分别生成4个顶点
		const float xMin = bboxMin.X;
		const float xMax = bboxMax.X;
		const float yMin = bboxMin.Y;
		const float yMax = bboxMax.Y;
		const float zMin = bboxMin.Z;
		const float zMax = bboxMax.Z;
		
		const int indexBase = verts.Num();
		
		//bottom
		verts.Add(FVector(xMin, yMin, zMin));
		verts.Add(FVector(xMax, yMin, zMin));
		verts.Add(FVector(xMax, yMax, zMin));
		verts.Add(FVector(xMin, yMax, zMin));
		// front
		verts.Add(FVector(xMin, yMin, zMin));
		verts.Add(FVector(xMax, yMin, zMin));
		verts.Add(FVector(xMax, yMin, zMax));
		verts.Add(FVector(xMin, yMin, zMax));
		// Right
		verts.Add(FVector(xMax, yMin, zMin));
		verts.Add(FVector(xMax, yMax, zMin));
		verts.Add(FVector(xMax, yMin, zMax));
		verts.Add(FVector(xMax, yMax, zMax));
		// Left
		verts.Add(FVector(xMin, yMin, zMin));
		verts.Add(FVector(xMin, yMax, zMin));
		verts.Add(FVector(xMin, yMax, zMax));
		verts.Add(FVector(xMin, yMin, zMax));
		// Back
		verts.Add(FVector(xMin, yMax, zMin));
		verts.Add(FVector(xMax, yMax, zMin));
		verts.Add(FVector(xMax, yMax, zMax));
		verts.Add(FVector(xMin, yMax, zMax));
		// Top
		verts.Add(FVector(xMin, yMin, zMax));
		verts.Add(FVector(xMax, yMin, zMax));
		verts.Add(FVector(xMax, yMax, zMax));
		verts.Add(FVector(xMin, yMax, zMax));
		
		// 三角形索引生成; 每个面由2个三角形组成，每个三角形3个顶点索引
		// Bottom
		triangles.Add(indexBase + 0);
		triangles.Add(indexBase + 1);
		triangles.Add(indexBase + 3);
		triangles.Add(indexBase + 1);
		triangles.Add(indexBase + 2);
		triangles.Add(indexBase + 3);
		// Front
		triangles.Add(indexBase + 4);
		triangles.Add(indexBase + 6);
		triangles.Add(indexBase + 5);
		triangles.Add(indexBase + 4);
		triangles.Add(indexBase + 7);
		triangles.Add(indexBase + 6);
		// Right
		triangles.Add(indexBase + 8);
		triangles.Add(indexBase + 10);
		triangles.Add(indexBase + 9);
		triangles.Add(indexBase + 9);
		triangles.Add(indexBase + 10);
		triangles.Add(indexBase + 11);
		// Left
		triangles.Add(indexBase + 12);
		triangles.Add(indexBase + 13);
		triangles.Add(indexBase + 14);
		triangles.Add(indexBase + 12);
		triangles.Add(indexBase + 14);
		triangles.Add(indexBase + 15);
		// Back
		triangles.Add(indexBase + 16);
		triangles.Add(indexBase + 17);
		triangles.Add(indexBase + 18);
		triangles.Add(indexBase + 16);
		triangles.Add(indexBase + 18);
		triangles.Add(indexBase + 19);
		// Top
		triangles.Add(indexBase + 22);
		triangles.Add(indexBase + 21);
		triangles.Add(indexBase + 20);
		triangles.Add(indexBase + 20);
		triangles.Add(indexBase + 23);
		triangles.Add(indexBase + 22);
		
		// 法线和切线生成; 为每个顶点设置正确的法线向量和切线向量，确保光照计算正确
		// Bottom
		normals.Add(FVector(0, 0, -1));
		normals.Add(FVector(0, 0, -1));
		normals.Add(FVector(0, 0, -1));
		normals.Add(FVector(0, 0, -1));
		// Front
		normals.Add(FVector(0, -1, 0));
		normals.Add(FVector(0, -1, 0));
		normals.Add(FVector(0, -1, 0));
		normals.Add(FVector(0, -1, 0));
		// Right
		normals.Add(FVector(1, 0, 0));
		normals.Add(FVector(1, 0, 0));
		normals.Add(FVector(1, 0, 0));
		normals.Add(FVector(1, 0, 0));
		// Left
		normals.Add(FVector(-1, 0, 0));
		normals.Add(FVector(-1, 0, 0));
		normals.Add(FVector(-1, 0, 0));
		normals.Add(FVector(-1, 0, 0));
		// Back
		normals.Add(FVector(0, 1, 0));
		normals.Add(FVector(0, 1, 0));
		normals.Add(FVector(0, 1, 0));
		normals.Add(FVector(0, 1, 0));
		// Top
		normals.Add(FVector(0, 0, 1));
		normals.Add(FVector(0, 0, 1));
		normals.Add(FVector(0, 0, 1));
		normals.Add(FVector(0, 0, 1));

		// Bottom
		tangents.Add(FProcMeshTangent(1, 0, 0));
		tangents.Add(FProcMeshTangent(1, 0, 0));
		tangents.Add(FProcMeshTangent(1, 0, 0));
		tangents.Add(FProcMeshTangent(1, 0, 0));
		// Front
		tangents.Add(FProcMeshTangent(0, 0, 1));
		tangents.Add(FProcMeshTangent(0, 0, 1));
		tangents.Add(FProcMeshTangent(0, 0, 1));
		tangents.Add(FProcMeshTangent(0, 0, 1));
		// Right
		tangents.Add(FProcMeshTangent(0, 0, 1));
		tangents.Add(FProcMeshTangent(0, 0, 1));
		tangents.Add(FProcMeshTangent(0, 0, 1));
		tangents.Add(FProcMeshTangent(0, 0, 1));
		// Left
		tangents.Add(FProcMeshTangent(0, 1, 0));
		tangents.Add(FProcMeshTangent(0, 1, 0));
		tangents.Add(FProcMeshTangent(0, 1, 0));
		tangents.Add(FProcMeshTangent(0, 1, 0));
		// Back
		tangents.Add(FProcMeshTangent(0, 0, 1));
		tangents.Add(FProcMeshTangent(0, 0, 1));
		tangents.Add(FProcMeshTangent(0, 0, 1));
		tangents.Add(FProcMeshTangent(0, 0, 1));
		// Top
		tangents.Add(FProcMeshTangent(1, 0, 0));
		tangents.Add(FProcMeshTangent(1, 0, 0));
		tangents.Add(FProcMeshTangent(1, 0, 0));
		tangents.Add(FProcMeshTangent(1, 0, 0));
		
		const FLinearColor Color = { 1.0, 1.0, 0.0, 1.0 };
		for (int i = 0; i < 24; i++) {
			colors.Add(Color);
		}
	};
	
	// 高度场遍历
	for (int x = 0; x < this->HeightField->width; x++) {
		for (int y = 0; y < this->HeightField->height; y++) {
			int idx = x + y * this->HeightField->width;
			rcSpan* nowSpan = this->HeightField->spans[idx];
			
			while (nowSpan) {
				drawSpan(*nowSpan, x, y);
				nowSpan = nowSpan->next;
			}
		}
	}
	
	this->ProceduralMesh->CreateMeshSection_LinearColor(0, verts, triangles, normals, uv0, colors, tangents, false);
	if (this->VolMaterial) {
		this->ProceduralMesh->SetMaterial(0, this->VolMaterial);
	}
}