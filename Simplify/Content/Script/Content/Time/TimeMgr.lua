---
---@brief 游戏世界时间管理
---

local TimeGlobalConfig = require('Content/Time/Config/TimeGlobalConfig')

---@class TimeMgr:MdBase
---@field CurTimeGlobalConfig number
local TimeMgr = class.class'TimeMgr': extends 'MdBase' {
--[[public]]
    ctor = function()end,
    Tick = function()end,
    GetCurTimeDisplay = function()end,
--[[private]]
    CurTimeGlobalConfig = nil,
    Year = nil,
    Month = nil,
    Day = nil,
    Hour = nil,
    Minute = nil,
}
function TimeMgr:ctor()
    self.CurTimeGlobalConfig = TimeGlobalConfig.TimeFlowRate
    self.Year = 2000
    self.Month = 7
    self.Day = 28
    self.Hour = 12
    self.Minute = 0
end
function TimeMgr:Tick(DeltaTime)
    
end
local function FmtTime(Number)
    return Number < 10 and ('0' .. tostring(Number)) or tostring(Number)
end
function TimeMgr:GetCurTimeDisplay()
    local str = tostring(self.Year)
    str = str .. '/' .. FmtTime(self.Month)
    str = str .. '/' .. FmtTime(self.Day)
    str = str .. '-' .. FmtTime(self.Hour)
    str = str .. ':' .. FmtTime(self.Minute)
    return str
end