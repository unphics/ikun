
---
---@brief   游戏世界时间管理
---@author  zys
---@data    Sun May 04 2025 13:53:30 GMT+0800 (中国标准时间)
---

local function FmtTime(Number)
    return Number < 10 and ('0' .. tostring(Number)) or tostring(Number)
end

---@class TimeMgr
---@field ConstTimeFlowRate number 游戏的时间流速
---@field GameSpeed number
---@field Year   number 年
---@field Month  number 月
---@field Day    number 日
---@field Hour   number 时
---@field Minute number 分
---@field Second number 秒
local TimeMgr = class.class'TimeMgr' {
    ctor = function()end,
    TickTimeMgr = function()end,
    GetCurTimeDisplay = function()end,
    SetGameSpeed = function()end,
    GetGameSpeed = function()end,
    _UpdateGameTime = function()end,
    ConstTimeFlowRate = nil,
    Year = nil,
    Month = nil,
    Day = nil,
    Hour = nil,
    Minute = nil,
    Second = nil,
}

---@public 初始化时间管理器的信息
function TimeMgr:ctor()
    self.ConstTimeFlowRate = ConfigMgr:GetGlobalConst('TimeFlowRate') or 30
    ---@todo declare
    self.ConstSecondRadix = ConfigMgr:GetGlobalConst('SecondRadix') or 60
    self.ConstMinuteRadix = ConfigMgr:GetGlobalConst('MinuteRadix') or 60
    self.ConstHourRadix = ConfigMgr:GetGlobalConst('HourRadix') or 24
    self.ConstDayRadix = ConfigMgr:GetGlobalConst('DayRadix') or 30
    self.ConstMonthRadix = ConfigMgr:GetGlobalConst('MonthRadix') or 12
    
    self.GameSpeed = ConfigMgr:GetGlobalConst('GameSpeed') or 1
    self.Year = 2000
    self.Month = 7
    self.Day = 28
    self.Hour = 3
    self.Minute = 0
    self.Second = 0
end

---@public [Tick] 运行时间管理器
function TimeMgr:TickTimeMgr(DeltaTime)
    self:_UpdateGameTime(DeltaTime)
end

---@public 设置游戏时间流速
---@param Speed integer
function TimeMgr:SetGameSpeed(Speed)
    if not Speed or type(Speed) ~= "number" or Speed < 0 then
        return log.error('TimeMgr:SetGameSpeed() : 参数错误', Speed)
    end
    self.GameSpeed = Speed
    UE.UGameplayStatics.SetGlobalTimeDilation(world_util.World, Speed)
    log.info('游戏速度为'..tostring(Speed)..'倍')
end

---@public [Pure] 获取当前的游戏时间流速
---@return integer
function TimeMgr:GetGameSpeed()
    return self.GameSpeed
end

---@public 获取当前时间的显示信息
function TimeMgr:GetCurTimeDisplay()
    local str = tostring(self.Year)
    str = str .. '/' .. FmtTime(self.Month)
    str = str .. '/' .. FmtTime(self.Day)
    str = str .. '-' .. FmtTime(self.Hour)
    str = str .. ':' .. FmtTime(self.Minute)
    return str
end

---@private 更新时间
function TimeMgr:_UpdateGameTime(DeltaTime)
    self.Second = self.Second + (DeltaTime * self.ConstTimeFlowRate)
    while self.Second >= self.ConstSecondRadix do -- 秒级更新
        self.Second = self.Second - self.ConstSecondRadix
        self.Minute = self.Minute + 1
        if self.Minute >= self.ConstMinuteRadix then -- 分钟级更新
            self.Minute = 0
            self.Hour = self.Hour + 1
            self:_OnHourUpdate()
            if self.Hour >= self.ConstHourRadix then -- 小时级更新
                self.Hour = 0
                self.Day = self.Day + 1
                if self.Day > self.ConstDayRadix then
                    self.Day = 1
                    self.Month = self.Month + 1
                    if self.Month > self.ConstMonthRadix then
                        self.Month = 1
                        self.Year = self.Year + 1
                    end
                end
            end
        end
    end
end

---@private
function TimeMgr:_OnHourUpdate()
    if self.Hour == 4 then
        RoleMgr:LateAtNight()
    end
end

return TimeMgr