---
---@brief
---

---@class MsgBusComp: MsgBusComp_C
local M = UnLua.Class()

-- function M:Initialize(Initializer)
-- end

-- function M:ReceiveBeginPlay()
-- end

-- function M:ReceiveEndPlay()
-- end

-- function M:ReceiveTick(DeltaSeconds)
-- end

---@public [Client] [Server]
function M:TriggerEvent(EventName, ...)
    if not self.Event[EventName] then
        log.warn('Failed to trigger nil event')
        return
    end
    for _, Listener in ipairs(self.Event[EventName]) do
        if obj_util.is_valid(Listener.FnSelf) then
            Listener.Fn(Listener.FnSelf, ...)
        end
    end
end

---@public [Client] [Server]
---@param EventName string
---@param FnSelf UObject
---@param Fn function
function M:RegEvent(EventName, FnSelf, Fn)
    if not self.Event then
        self.Event = {}
    end
    if not self.Event[EventName] then
        self.Event[EventName] = {}
    end
    local Listener = {
        Fn = Fn,
        FnSelf = FnSelf,
    }
    table.insert(self.Event[EventName], Listener)
end

---@public [Client] [Server]
function M:PrepareInitChrDataEvent()
    self.InitChrDataEventTimerHandle = async_util.timer(self:GetOwner(),  function()
        self:TriggerEvent('ChrInitData')
        UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self:GetOwner(), self.InitChrDataEventTimerHandle)
        self.InitChrDataEventTimerHandle = nil
    end, 1, false)
end

---@public [Client] [Server]
function M:PrepareInitChrDisplayEvent()
    self.InitChrDisplayEventTimerHandle = async_util.timer(self:GetOwner(),  function()
        self:TriggerEvent('ChrInitDisplay')
        UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self:GetOwner(), self.InitChrDisplayEventTimerHandle)
        self.InitChrDisplayEventTimerHandle = nil
    end, 2, false)
end

return M
