
---
---@brief   更新Npc接待Player访问的信息
---@author  zys
---@data    Wed Oct 22 2025 09:47:14 GMT+0800 (中国标准时间)
---

---@class ReceptionSensor: GSensor
---@field _ReceptionComp BP_ReceptionComp
local ReceptionSensor = class.class 'ReceptionSensor':extends'GSensor' {}

---@override
function ReceptionSensor:ctor(Agent)
    class.GSensor.ctor(self, Agent)
    local avatar = rolelib.chr(self._Agent)
    local receptionComp = avatar:GetController().BP_ReceptionComp ---@as BP_ReceptionComp
    self._ReceptionComp = receptionComp
end

---@override
function ReceptionSensor:TickSensor(DeltaTime)
    self._Agent.Memory:SetState('Recepting', false)
    
    local newState = self._ReceptionComp:GetVisitorCount() > 0
    local oldState = self._Agent.Memory:GetState('Recepting')
    self._Agent.Memory:SetState('Recepting', newState)
    if not newState and oldState then
        local config = ConfigMgr:GetConfig('Goal')['Reception'] ---@as GoalConfig
        local desiredStates = goap.util.make_states_from_config(config.DesiredState)
        local goal = class.new'GGoal'(config.GoalName, desiredStates) ---@as GGoal
        self._Agent:AddGoal(goal, 1)
        log.dev('添加Goal:玩家访问Npc')
    end
end

return ReceptionSensor