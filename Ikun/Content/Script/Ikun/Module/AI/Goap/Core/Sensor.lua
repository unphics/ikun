
---
---@brief   每隔一段时间采集信息写入决策系统
---@author  zys
---@data    Sat Sep 27 2025 20:42:39 GMT+0800 (中国标准时间)
---

---@class GSensor
---@field _Agent GAgent
local GSensor = class.class 'GSensor' {
    _Agent = nil,
}

---@public
function GSensor:ctor(Agent)
    self._Agent = Agent
end

---@public
function GSensor:TickSensor(DeltaTime)
    local time = TimeMgr.Hour
    if time > 7 and time < 9 then -- 早晨
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

return GSensor