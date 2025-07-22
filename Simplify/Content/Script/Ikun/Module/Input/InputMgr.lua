
---
---@brief   客户端全局输入管理
---@author  zys
---@data    Sat Jul 19 2025 20:53:10 GMT+0800 (中国标准时间)
---

---@class InputMgr
---@field _InputEvents table<UObject, table<IADef, fun(PC, ActionValue, ElapsedSeconds, TriggeredSeconds, InputAction)>>
---@field _InputOwnership table
local InputMgr = {}

InputMgr._InputEvents = {}
InputMgr._InputOwnership = {}

---@public
InputMgr.ObtainOwnership = function(Object)

end

---@public
InputMgr.ReliquishOwnership = function(Object)

end

---@public
---@param Object UObject
---@param IADef IADef
---@param fn fun(UObject, ActionValue, ElapsedSeconds, TriggeredSeconds, InputAction)
InputMgr.RegisterInputAction = function(Object, IADef, fn)
    InputMgr._InputEvents[Object] = {}
    InputMgr._InputEvents[Object][IADef] = fn
end

---@public
---@param Object UObject
InputMgr.UnregisterInputAction = function(Object)
    InputMgr._InputEvents = nil
end

---@public
---@todo 当前的输入所有权暂定
---@param IADef IADef
InputMgr.TriggerInputAction = function(IADef, ActionValue, ElapsedSeconds, TriggeredSeconds, InputAction)
    local ownershipObject = next(InputMgr._InputEvents) ---@type UObject
    if ownershipObject then
        local fn = InputMgr._InputEvents[ownershipObject][IADef]
        if fn then
            fn(ownershipObject, ActionValue, ElapsedSeconds, TriggeredSeconds, InputAction)
        end
    end
end

return InputMgr