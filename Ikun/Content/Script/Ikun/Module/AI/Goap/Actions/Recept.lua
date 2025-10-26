
---
---@brief   接待
---@author  zys
---@data    Sun Oct 26 2025 16:10:05 GMT+0800 (中国标准时间)
---

---@class ReceptAction: GAction
local ReceptAction = class.class'ReceptAction':extends'GAction' {}

---@override
function ReceptAction:ActionStart(Agent)
    class.GAction.ActionStart(self, Agent)
    log.dev('开始')
end

---@override
function ReceptAction:ActionTick(Agent, DeltaTime)
    local chr = rolelib.chr(Agent)
    if not chr then
        return
    end
    local ownerReceptComp = chr:GetController().BP_ReceptionComp ---@as BP_ReceptionComp
    if ownerReceptComp:GetVisitorCount() <= 0 then
        self:EndAction(true)
    end
end

---@override
function ReceptAction:ActionEnd(Agent, bSuccess)
    log.dev('结束')
end

return ReceptAction