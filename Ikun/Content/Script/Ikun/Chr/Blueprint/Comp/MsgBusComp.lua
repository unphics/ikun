

---@type MsgBusComp_C
local M = UnLua.Class()

function M:Initialize(Initializer)
    self.Event = {}
end

-- function M:ReceiveBeginPlay()
-- end

-- function M:ReceiveEndPlay()
-- end

-- function M:ReceiveTick(DeltaSeconds)
-- end

---@public
function M:TriggerEvent(EventName, ...)
    if not self.Event[EventName] then
        return
    end
    for _, Listener in ipairs(self.Event[EventName]) do
        Listener.Fn(Listener.FnSelf, ...)
    end
end

---@public
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
        FnSelf = FnSelf
    }
    table.insert(self.Event[EventName], Listener)
end

return M
