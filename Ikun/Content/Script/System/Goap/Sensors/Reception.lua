
---
---@brief   更新Npc接待Player访问的信息
---@author  zys
---@data    Wed Oct 22 2025 09:47:14 GMT+0800 (中国标准时间)
---

---@class ReceptionSensor: GSensor
---@field private _OwnerAgent GAgent
local ReceptionSensor = class.class 'ReceptionSensor':extends'GSensor' {}

---@override
function ReceptionSensor:ctor(Agent)
    class.GSensor.ctor(self, Agent)
    self._OwnerAgent = Agent
end

---@override
function ReceptionSensor:TickSensor(DeltaTime)
    local comp = self:_GetReceptionComp()
    if not comp then
        return
    end

    local newState = comp:GetVisitorCount() > 0
    local oldState = self._Agent.Memory:GetState('Recepting')
    if not oldState and newState then
        self._Agent.Memory:SetState('Recepting', newState)
        local config = ConfigMgr:GetConfig('Goal')['Reception'] ---@as GoalConfig
        local desiredStates = goap.util.make_states_from_config(config.DesiredState)
        local goal = class.new'GGoal'(config.GoalName, desiredStates) ---@as GGoal
        self._Agent:AddGoal(goal, 1)
        log.info('添加接待目标', rolelib.role(self._Agent):RoleName())
        self._Agent:MakePlan()
    end
end

---@private
---@return BP_ReceptionComp?
function ReceptionSensor:_GetReceptionComp()
    local avatar = rolelib.chr(self._OwnerAgent)
    if avatar then
        local comp = avatar:GetController().BP_ReceptionComp ---@as BP_ReceptionComp
        return comp
    end
end

return ReceptionSensor