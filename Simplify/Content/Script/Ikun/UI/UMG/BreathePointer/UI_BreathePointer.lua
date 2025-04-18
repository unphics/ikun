---
---@brief 一个有趣的呼吸指针; 参考上古卷轴5天际
---@author zys
---@data Sat Apr 05 2025 15:36:54 GMT+0800 (中国标准时间)
---

local BREATHE_DURATION_PEACE = 2 -- 平静时一次呼吸时间
local MAX_OPEN_AMPLITUDE = 30 -- 最大的张开幅度
local MIN_SHRINK_AMPLITUDE = 15 -- 最小的收缩幅度

---@class UI_BreathePointer: UI_BreathePointer_C
local M = UnLua.Class()

--function M:Initialize(Initializer)
--end

function M:PreConstruct(IsDesignTime)
    self.CurBreatheDuration = BREATHE_DURATION_PEACE -- 当前的一次呼吸的时间
    self.CurTime = 0
end

function M:Construct()
end

function M:Tick(MyGeometry, InDeltaTime)
    self.CurTime = self.CurTime + InDeltaTime
    if self.CurTime > self.CurBreatheDuration then
        self.CurTime = self.CurTime - self.CurBreatheDuration
    end
    local Rate = self.BreathCurve:GetFloatValue(self.CurTime / self.CurBreatheDuration)
    local Result = (MAX_OPEN_AMPLITUDE - MIN_SHRINK_AMPLITUDE) * Rate + MIN_SHRINK_AMPLITUDE
    UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.CvsPointer):SetSize(UE.FVector2D(Result, Result))
end

return M
