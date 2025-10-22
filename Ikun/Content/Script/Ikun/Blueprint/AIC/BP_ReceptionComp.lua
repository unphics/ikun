
---
---@brief   Npc接待玩家组件, 其实就是交互
---@author  zys
---@data    Tue Oct 21 2025 22:50:52 GMT+0800 (中国标准时间)
---

---@class BP_ReceptionComp: BP_ReceptionComp_C
---@field _tbVisit BP_PC_Base[]
local BP_ReceptionComp = UnLua.Class()

---@override
function BP_ReceptionComp:ReceiveBeginPlay()
    self.Overridden.ReceiveBeginPlay(self)
    self._tbVisit = {}

    if not self:GetOwner():Cast(UE.AAIController) then
        log.error('这玩意只能挂在AIC上给Npc用!!!')
    end
end

---@override
function BP_ReceptionComp:ReceiveEndPlay(EndPlayReason)
    self.Overridden.ReceiveEndPlay(self, EndPlayReason)
    self._tbVisit = {}
end

---@public
---@param InPlayer BP_PC_Base
function BP_ReceptionComp:BeginVisitNpc(InPlayer)
    log.info(log.key.chat, '玩家开始访问Npc', InPlayer)
    table.insert(self._tbVisit, InPlayer)
end

---@public
---@param InPlayer BP_PC_Base
function BP_ReceptionComp:EndVisitNpc(InPlayer)
    log.info(log.key.chat, '玩家结束访问Npc', InPlayer)
    for i, chr in ipairs(self._tbVisit) do
        if chr == InPlayer then
            table.remove(self._tbVisit, i)
            break
        end
    end
end

---@public
---@return number
function BP_ReceptionComp:GetVisitorCount()
    return #self._tbVisit
end

return BP_ReceptionComp