
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
end

return GSensor