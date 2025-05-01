---
---@brief 游戏世界时间管理
---

local TimeCfg = require('Content/Time/Config/TimeCfg')

---@class TimeMgr:MdBase
---@field TimeFlowRate number 
---@field CurFlowTime number
local TimeMgr = class.class'TimeMgr': extends 'MdBase' {
--[[public]]
    ctor = function()end,
    Tick = function()end,
    GetCurTimeDisplay = function()end,
--[[private]]
    UpdateDispValue = function()end,
    TimeFlowRate = nil,
    CurFlowTime = nil,
    Year = nil,
    Month = nil,
    Day = nil,
    Hour = nil,
    Minute = nil,
}
function TimeMgr:ctor()
    self.TimeFlowRate = TimeCfg.TimeFlowRate
    self.CurFlowTime = 0
    self.Year = 2000
    self.Month = 7
    self.Day = 28
    self.Hour = 12
    self.Minute = 0
end
function TimeMgr:Tick(DeltaTime)
    self.CurFlowTime = self.CurFlowTime + (DeltaTime * self.TimeFlowRate)
    self:UpdateDispValue()
    -- log.dev(self:GetCurTimeDisplay())
end
function TimeMgr:UpdateDispValue()
    if self.CurFlowTime < TimeCfg.SecondRadix then
        return
    end
    self.CurFlowTime = self.CurFlowTime - TimeCfg.SecondRadix
    self.Minute = self.Minute + 1
    if self.Minute < TimeCfg.MinuteRadix then
        return
    end
    self.Minute = 0
    self.Hour = self.Hour + 1
    if self.Hour < TimeCfg.HourRadix then
        return
    end
    self.Hour = 0
    self.Day = self.Day + 1
    if self.Day < TimeCfg.DayRadix then
        return
    end
    self.Day = 0
    self.Month = self.Month + 1
    if self.Month < TimeCfg.MonthRadix then
        return
    end
    self.Year = self.Year + 1
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