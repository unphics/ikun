

local fficlass = require("Core/FFI/fficlass")
local vec3 = require('Core/FFI/vec3')

---@class NavPathData
---@field private _CurSegIdx number
---@field private _NavPoints vec3[]
---@field private _PointNum number
---@field private _FindingObj integer
local NavPathData = fficlass.define('NavPathData', [[
    typedef struct {
        int _CurSegIdx;
        vec3 _NavPoints [32];
        int _PointNum;
        void* _FindingObj;
    } NavPathData;
]])

function NavPathData:Clear()
    self._CurSegIdx = 1
    self._PointNum = 0
    self._FindingObj = nil
end

---@public 生成寻路数据并保存
---@param Chr ACharacter
---@param Start FVector
---@param End FVector
---@param First FVector@opt 当真实起始点不在寻路范围内而又可接受时, 加入寻路数据并作为一个寻路起始点
---@param FindedCallback fun(NavPathData: NavPathData, bSuccess: boolean)
function NavPathData.GenNavPathData(Chr, Start, End, First, FindedCallback)
    local data = NavPathData() ---@type NavPathData
    data:FindNavPath()
    return data
end

function NavPathData:FindNavPath(Chr, Start, End, First, FindedCallback)
    local findingObj = UE.UNavPathFinding.FindPathAsync(Chr, Start, End) ---@type UNavPathFinding

    if not findingObj or not findingObj:IsFindValid() then
        FindedCallback(_, false)
    end

    self:Clear()

    if First then
        self._NavPoints[0]:fromUE(First)
        self._PointNum = self._PointNum + 1
    end

    findingObj.OnPathFindFinishedEvent:Add(Chr, function(_, PathPoints)
        local bSuccess = PathPoints:Length() > 1.5
        self:_OnPathFindFinished(PathPoints)
        FindedCallback(self, bSuccess)
    end)
    self._FindingObj = ffi.cast('void*', findingObj)
end

function NavPathData:CancelFind()
    log.debug('NavPathData:CancelFind()')
    if self._FindingObj ~= nil then
        self._FindingObj.CancelFind(self._FindingObj)
    end
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
    for i = 1, PathPoints:Length() do
        self._NavPoints[self._PointNum]:fromUE(PathPoints:Get(i))
        self._PointNum = self._PointNum + 1
    end
    self._FindingObj = nil
end

NavPathData = NavPathData:Register()

return NavPathData