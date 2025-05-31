---
---@brief 寻路数据
---@author zys
---@ref https://www.cnblogs.com/Xi-mo/p/9771397.html
---     https://zenn.dev/neighbortone/articles/2820a632e4a7c8
---@data Thu Apr 03 2025 02:44:59 GMT+0800 (中国标准时间)
---@todo 1.增加一个平滑函数, 把锐角的转折点平滑处理以优化表现
---      2.SegIdx外部管理, 如共享寻路数据
---      3.可视化寻路路径(DrawDebug)
---      4.动态避障
---

---@class NavMoveData
---@field tbNavPoint FVector[]
---@field CurSegIdx number
local NavMoveData = class.class 'NavMoveData' {
--[[public]]
    ctor = function()end,
    GetPathData = function()end,
    IsValid = function()end,
    GetCurTarget = function()end,
    AdvanceSeg = function()end,
    ProjectPointToNavMesh = function()end,
--[[private]]
    tbNavPoint = nil,
    CurSegIdx = nil,
}
function NavMoveData:ctor()
end
---@public 清除数据, 初始化数据
function NavMoveData:Clear()
    self.tbNavPoint = {}
    self.CurSegIdx = 2
end
---@public 生成寻路数据并保存
---@param Chr ACharacter
---@param Start FVector
---@param End FVector
---@param First FVector@opt 当真实起始点不在寻路范围内而又可接受时, 加入寻路数据并作为一个寻路起始点
---@return boolean
function NavMoveData:GenPathData(Chr, Start, End, First)
    local UENavMoveData = UE.UNavigationSystemV1.FindPathToLocationSynchronously(Chr, Start,
        End, Chr, nil)
    if UENavMoveData.PathPoints:Length() < 2 then
        return false
    end
    self:Clear()
    if First then
        table.insert(self.tbNavPoint, First)
    end
    for i = 1, UENavMoveData.PathPoints:Length() do
        local Point = UENavMoveData.PathPoints:Get(i)
        table.insert(self.tbNavPoint, Point)
    end
    return self:IsValid()
end
---@public 数据有效
---@return boolean
function NavMoveData:IsValid()
    return self.tbNavPoint[self.CurSegIdx] ~= nil
end
---@public
---@return boolean
function NavMoveData:IsFinish()
    return self.CurSegIdx > #self.tbNavPoint
end
---@public 获取当前段的寻路目标: CurSegEndLoc
function NavMoveData:GetCurSegEnd()
    return self.tbNavPoint[self.CurSegIdx]
end
---@public 推进到下一段
function NavMoveData:AdvanceSeg()
    self.CurSegIdx = self.CurSegIdx + 1
end
---@public [Tool] 计算Chr到当前段目标点的2d方向; 注意:未Normalized
---@param Chr ACharacter
---@return FVector
function NavMoveData:CalcChr2CurSegEndDir2D(Chr)
    local SelfChrAgentLoc = Chr:GetNavAgentLocation()
    local CurSegEndLoc = self:GetCurSegEnd()
    local ToCurSegEndDir = CurSegEndLoc - SelfChrAgentLoc
    ToCurSegEndDir.Z = 0
    return ToCurSegEndDir
end
---@public [StaticFn] 投射目标点到NavMesh上
---@param Point FVector | AActor
---@param QueryEvent FVector@[opt]
---@return boolean | nil, FVector
function NavMoveData.ProjectPointToNavMesh(World, Point, QueryEvent)
    if not World then
        return log.error('NavMoveData:ProjectPointToNavMesh(): Attemp to index a nil world')
    end
    local ProjectedPoint = UE.FVector(0, 0, 0)
    QueryEvent = QueryEvent or UE.FVector(0, 0, 0)
    local _Point = Point
    if Point.IsA then
        _Point = Point:K2_GetActorLocation()
    end
    local bSuccess = UE.UNavigationSystemV1.K2_ProjectPointToNavigation(World, _Point, 
        ProjectedPoint, nil, nil, QueryEvent)
    return bSuccess, ProjectedPoint
end
---@public [StaticFn] 范围内获取一个随机可达点
---@param OriginLoc FVector
---@return boolean, FVector
function NavMoveData.RandomNavPointInRadius(World, OriginLoc, Radius)
    local RandLoc = UE.FVector(0, 0, 0)
    local bSuccess = UE.UNavigationSystemV1.K2_GetRandomReachablePointInRadius(World, OriginLoc, RandLoc, Radius, nil, nil)
    return bSuccess, RandLoc
end

return NavMoveData