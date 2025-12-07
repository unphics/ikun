

local fficlass = require("Core/FFI/fficlass")

require('Core/FFI/vec3')

---@enum NavPathDataFindingState
local NavPathDataFindingState = {
    Init = 0,
    Finding = 1,
    Success = 2,
    Failure = 3,
}

---@class NavPathData
---@field private _CurSegIdx number
---@field private _NavPoints vec3[]
---@field private _PointNum number
---@field private _FindingObj integer
---@field private _FindingState NavPathDataFindingState
local NavPathData = fficlass.define('NavPathData2', [[
    typedef struct {
        int _CurSegIdx;
        vec3 _NavPoints [32];
        int _PointNum;
        void* _FindingObj;
        int _FindingState;
    } NavPathData2;
]])

function NavPathData:Clear()
    self._CurSegIdx = 1
    self._PointNum = 0
    self._FindingObj = nil
    self._FindingState = NavPathDataFindingState.Init
end

---@public 生成寻路数据并保存
---@param Chr ACharacter
---@param Start FVector
---@param End FVector
---@param First FVector@opt 当真实起始点不在寻路范围内而又可接受时, 加入寻路数据并作为一个寻路起始点
---@param FindedCallback fun(NavPathData: NavPathData, bSuccess: boolean)
function NavPathData.GenNavPathData(Chr, Start, End, First, FindedCallback)
    local data = NavPathData()
    local finding = UE.UNavPathFinding.FindPathAsync(Chr, Start, End)
    data._FindingState = NavPathDataFindingState.Finding

    if not finding or not finding:IsFindValid() then
        data._FindingState = NavPathDataFindingState.Failure
    end

    data:Clear()

    if First then
        data._NavPoints[0]:fromUE(First)
        data._PointNum = data._PointNum + 1
    end

    finding.OnPathFindFinishedEvent:Add(Chr, function(_, PathPoints)
        data:_OnPathFindFinished(PathPoints)
        FindedCallback(data, data._FindingState == NavPathDataFindingState.Success)
    end)
    data._FindingObj = ffi.cast('void*', finding)
    return data
end

---@public 推进到下一段
function NavPathData:AdvanceSeg()
    self._CurSegIdx = self._CurSegIdx + 1
end

---@public 获取当前段的寻路目标
---@return vec3
function NavPathData:GetCurSegEnd()
    return self._NavPoints[self._CurSegIdx]
end

---@public
---@return boolean
function NavPathData:IsNavFinished()
    return self._CurSegIdx >= self._PointNum
end

---@private
---@param PathPoints TArray<FVector>
function NavPathData:_OnPathFindFinished(PathPoints)
    if PathPoints:Length() < 2 then
        self._FindingState = NavPathDataFindingState.Failure
    end
    self._FindingState = NavPathDataFindingState.Success
    for i = 1, PathPoints:Length() do
        self._NavPoints[self._PointNum]:fromUE(PathPoints:Get(i))
        self._PointNum = self._PointNum + 1
    end
    self._FindingObj = nil
end

NavPathData = NavPathData:Register()

return NavPathData