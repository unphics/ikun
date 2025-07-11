---
---@brief 游戏世界时间管理
---@author zys
---@data Sun May 04 2025 13:53:30 GMT+0800 (中国标准时间)
---

local TimeCfg = require('Content/Time/Config/TimeCfg')

---@class TimeMgr:MdBase
---@field ConstTimeFlowRate number 游戏的时间流速
---@field GameSpeed number
---@field Year   number 年
---@field Month  number 月
---@field Day    number 日
---@field Hour   number 时
---@field Minute number 分
---@field Second number 秒
local TimeMgr = class.class'TimeMgr': extends 'MdBase' {
--[[public]]
    ctor = function()end,
    Tick = function()end,
    GetCurTimeDisplay = function()end,
    SetGameSpeed = function()end,
    GetGameSpeed = function()end,
--[[private]]
    UpdateGameTime = function()end,
    ConstTimeFlowRate = nil,
    Year = nil,
    Month = nil,
    Day = nil,
    Hour = nil,
    Minute = nil,
    Second = nil,
}
function TimeMgr:ctor()
    self.ConstTimeFlowRate = TimeCfg.TimeFlowRate
    self.GameSpeed = TimeCfg.GameSpeed
    self.Second = 0
    self.Year = 2000
    self.Month = 7
    self.Day = 28
    self.Hour = 12
    self.Minute = 0
end
function TimeMgr:Tick(DeltaTime)
    self:UpdateGameTime(DeltaTime)
end
function TimeMgr:UpdateGameTime(DeltaTime)
    self.Second = self.Second + (DeltaTime * self.ConstTimeFlowRate)
    while self.Second >= TimeCfg.SecondRadix do -- 秒级更新
        self.Second = self.Second - TimeCfg.SecondRadix
        self.Minute = self.Minute + 1
        if self.Minute >= TimeCfg.MinuteRadix then -- 分钟级更新
            self.Minute = 0
            self.Hour = self.Hour + 1
            if self.Hour >= TimeCfg.HourRadix then -- 小时级更新
                self.Hour = 0
                self.Day = self.Day + 1
                if self.Day > TimeCfg.DayRadix then
                    self.Day = 1
                    self.Month = self.Month + 1
                    if self.Month > TimeCfg.MonthRadix then
                        self.Month = 1
                        self.Year = self.Year + 1
                    end
                end
            end
        end
    end
end
function TimeMgr:SetGameSpeed(Speed)
    if not Speed or type(Speed) ~= "number" or Speed < 0 then
        return log.error('TimeMgr:SetGameSpeed() : 参数错误', Speed)
    end
    self.GameSpeed = Speed
    UE.UGameplayStatics.SetGlobalTimeDilation(world_util.World, Speed)
    log.log('游戏速度为'..tostring(Speed)..'倍')
end
function TimeMgr:GetGameSpeed()
    return self.GameSpeed
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