
---
---@brief   世界状态
---@notice  将要废弃, 转而使用GMemory
---@author  zys
---@data    Thu Sep 25 2025 23:39:49 GMT+0800 (中国标准时间)
---

---@enum TimeMaskDef
local TimeMaskDef = {
    DayTime     = 1 << 0,   -- 白天/黑夜
    MorningTime = 1 << 1,   -- 早上/其他
}

---@class GWorldState
---@field States table<string, boolean>
---@field TimeMask integer
local GWorldState = class.class'GWorldState' {
    TimeMask = nil,
    States = nil,
}
function GWorldState:ctor()
    self.States = {}
    self.TimeMask = 0
end

---@public 检查BaseStates是否满足TargetStates的要求
---@param BaseStates table<string, boolean>
---@param TargetStates table<string, boolean>
---@return boolean
function GWorldState.IsStateCover(BaseStates, TargetStates)
    for name, value in pairs(TargetStates) do
        if BaseStates[name] ~= value then
            return false
        end
    end
    return true
end

---@public 计算未覆盖的数量
---@param BaseStates table<string, boolean>
---@param TargetStates table<string, boolean>
function GWorldState.CalcNoCoverNum(BaseStates, TargetStates)
    local num = 0
    for name, value in pairs(TargetStates) do
        if BaseStates[name] ~= value then
            num = num + 1
        end
    end
    return num
end


local _log = log.no
local state = 0

state = state | TimeMaskDef.DayTime
_log('设置白天', state)

state = state | TimeMaskDef.MorningTime
_log('设置早上', state)

local bDay = state & TimeMaskDef.DayTime ~= 0
_log('是否白天', bDay, state)

local need = TimeMaskDef.DayTime | TimeMaskDef.MorningTime
local bDayMorning = state & need == need
_log('是否白天且早上', bDayMorning)

state = state & ~TimeMaskDef.MorningTime
_log('清除早上', state)

local bMorning = state & TimeMaskDef.MorningTime ~= 0
_log('是否早上', bMorning)

bDayMorning = state & need == need
_log('是否白天且早上', bDayMorning)