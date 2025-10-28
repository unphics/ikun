
---
---@brief   默认
---@author  zys
---@data    Thu Oct 02 2025 20:36:53 GMT+0800 (中国标准时间)
---

---@class DefaultSensor: GSensor
local DefaultSensor = class.class 'DefaultSensor' : extends 'GSensor' {}

---@override
function DefaultSensor:TickSensor(DeltaTime)
    class.GSensor.TickSensor(self, DeltaTime)

    local time = TimeMgr.Hour
    if time >= 7 and time < 9 then -- 早晨
        self._Agent.Memory:SetState('Morning', true)
        self._Agent.Memory:SetState('Forenoon', false)
        self._Agent.Memory:SetState('Noon', false)
        self._Agent.Memory:SetState('Afternoon', false)
        self._Agent.Memory:SetState('Dusk', false)
        self._Agent.Memory:SetState('Evening', false)
    elseif time >= 9 and time < 12 then -- 上午
        self._Agent.Memory:SetState('Morning', false)
        self._Agent.Memory:SetState('Forenoon', true)
    elseif time >= 12 and time < 14 then -- 中午
        self._Agent.Memory:SetState('Forenoon', false)
        self._Agent.Memory:SetState('Noon', true)
    elseif time >= 14 and time < 18 then -- 下午
        self._Agent.Memory:SetState('Noon', false)
        self._Agent.Memory:SetState('Afternoon', true)
    elseif time >= 18 and time < 20 then -- 傍晚
        self._Agent.Memory:SetState('Afternoon', false)
        self._Agent.Memory:SetState('Dusk', true)
    else -- 晚上
        self._Agent.Memory:SetState('Dusk', false)
        self._Agent.Memory:SetState('Evening', true)
    end
end

return DefaultSensor