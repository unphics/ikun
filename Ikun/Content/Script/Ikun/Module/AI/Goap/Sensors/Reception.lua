
---
---@brief   更新Npc接待Player访问的信息
---@author  zys
---@data    Wed Oct 22 2025 09:47:14 GMT+0800 (中国标准时间)
---

---@class ReceptionClass: GSensor
---@field _ReceptionComp BP_ReceptionComp
local ReceptionClass = class.class 'ReceptionClass':extends'GSensor' {}

---@override
function ReceptionClass:ctor(Agent)
    class.GSensor.ctor(self, Agent)
    local avatar = rolelib.chr(self._Agent)
    local receptionComp = avatar:GetController().BP_ReceptionComp ---@as BP_ReceptionComp
    self._ReceptionComp = receptionComp
end

---@override
function ReceptionClass:TickSensor(DeltaTime)
    self._Agent.Memory:SetState('Recepting', false)
    
    local newState = self._ReceptionComp:GetVisitorCount() > 0
    local oldState = self._Agent.Memory:GetState('Recepting')
    self._Agent.Memory:SetState('Recepting', newState)
    if not newState and oldState then
        -- push goal
    end
end

return ReceptionClass