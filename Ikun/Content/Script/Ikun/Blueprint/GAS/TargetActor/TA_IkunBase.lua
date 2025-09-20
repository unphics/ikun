
---
---@brief   TargetActor的基类
---@author  zys
---@data    Wed Sep 17 2025 20:17:22 GMT+0800 (中国标准时间)
---

---@class TA_IkunBase: AIkunTargetActorBase
---@field TargetActorContext TargetActorContext
local TA_IkunBase = UnLua.Class()

---@override
function TA_IkunBase:ReceiveBeginPlay()
    self.bDestroyOnConfirmation = false
end

-- function TA_IkunBase:ReceiveEndPlay()
-- end

-- function TA_IkunBase:ReceiveTick(DeltaSeconds)
-- end

---@override
function TA_IkunBase:OnPreStartTargeting(Ability)
end

---@override
function TA_IkunBase:OnPostStartTargeting(Ability)
end

---@override
function TA_IkunBase:OnPreConfirmTargetingAndContinue()
    -- self:Multicast_DrawDebug()
end

---@override
function TA_IkunBase:OnPostConfirmTargetingAndContinue()
end

---@public
---@param Context TargetActorContext
function TA_IkunBase:InitTargetActor(Context)
    self.TargetActorContext = Context
end

return TA_IkunBase