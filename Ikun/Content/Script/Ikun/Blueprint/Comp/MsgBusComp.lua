---
---@brief   消息分发
---@author  zys
---@data    Tue Sep 23 2025 15:06:52 GMT+0800 (中国标准时间)
---

---@class MsgBusComp: MsgBusComp_C
local MsgBusComp = UnLua.Class()

---@public [Client] [Server] 触发事件
function MsgBusComp:TriggerMsg(EventName, ...)
    if not self.Event[EventName] then
        return log.warn('Failed to trigger nil event', EventName)
    end
    for _, Listener in ipairs(self.Event[EventName]) do
        if obj_util.is_valid(Listener.FnSelf) then
            Listener.Fn(Listener.FnSelf, ...)
        end
    end
end

---@public [Client] [Server] 注册事件监听
---@param EventName string
---@param FnSelf UObject
---@param Fn function
function MsgBusComp:RegMsg(EventName, FnSelf, Fn)
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

return MsgBusComp