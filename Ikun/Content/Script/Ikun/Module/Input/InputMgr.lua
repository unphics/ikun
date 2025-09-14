
---
---@brief   客户端全局输入管理
---@author  zys
---@data    Sat Jul 19 2025 20:53:10 GMT+0800 (中国标准时间)
---

---@class InputPower
---@field Object UObject
---@field bBorrowInput boolean

---@class InputMgr
---@field _InputEvents table<InputPower, table<IADef, table<TriggerEvent, fun(UObject, ActionValue, ElapsedSeconds, TriggeredSeconds, InputAction): boolean>>>
---@field _InputPowerStack InputPower[]
---@field _CachedInputPowerOwner UObject[]
local InputMgr = {}

InputMgr._InputEvents = {}
InputMgr._InputPowerStack = {}
InputMgr._CachedInputPowerOwner = {}

---@public 获取输入监听权
---@return InputPower
InputMgr.ObtainInputPower = function(Object)
    ---@type InputPower
    local item = {
        Object = Object,
        bBorrowInput = false
    }
    table.insert(InputMgr._InputPowerStack, item)
    InputMgr._RefreshCachedInputPowerOwner()
    return item
end

---@public 借出输入监听权
---@return InputPower
InputMgr.BorrowInputPower = function(Object)
    ---@type InputPower
    local item = {
        Object = Object,
        bBorrowInput = true
    }
    table.insert(InputMgr._InputPowerStack, item)
    InputMgr._RefreshCachedInputPowerOwner()
    return item
end

---@public 放弃输入监听权
---@param Power InputPower
InputMgr.ReliquishInputPower = function(Power)
    if not Power then
        return
    end
    for i, item in ipairs(InputMgr._InputPowerStack) do
        if item == Power then
            table.remove(InputMgr._InputPowerStack, i)
            break
        end
    end
    InputMgr._InputEvents[Power] = nil
    InputMgr._RefreshCachedInputPowerOwner()
end

---@private 刷新缓存的当前所有权拥有者
InputMgr._RefreshCachedInputPowerOwner = function()
    InputMgr._CachedInputPowerOwner = {}
    for i = #InputMgr._InputPowerStack, 1, -1 do
        local inputPower = InputMgr._InputPowerStack[i] ---@type InputPower
        table.insert(InputMgr._CachedInputPowerOwner, inputPower)
        if not inputPower.bBorrowInput then
            break
        end
    end
end

---@public 注册监听输入事件
---@param Power InputPower
---@param IADef IADef
---@param TriggerEvent TriggerEvent
---@param fn fun(UObject, ActionValue, ElapsedSeconds, TriggeredSeconds, InputAction): boolean
InputMgr.RegisterInputAction = function(Power, IADef, TriggerEvent, fn)
    if not InputMgr._InputEvents[Power] then
        InputMgr._InputEvents[Power] = {}
    end
    if not InputMgr._InputEvents[Power][IADef] then
        InputMgr._InputEvents[Power][IADef] = {}    
    end
    if InputMgr._InputEvents[Power][IADef][TriggerEvent] then
        return log.error('InputMgr.RegisterInputAction() 重复的输入事件监听')
    end
    InputMgr._InputEvents[Power][IADef][TriggerEvent] = fn
end

---@public 反注册监听输入
---@param Power InputPower
InputMgr.UnregisterInputAction = function(Power)
    if InputMgr._InputEvents[Power] then
        InputMgr._InputEvents[Power] = nil
    end
end

---@public 触发输入事件
---@param IADef IADef
InputMgr.TriggerInputAction = function(IADef, TriggerEvent, ActionValue, ElapsedSeconds, TriggeredSeconds, InputAction)
    ---@param power InputPower
    for _, power in ipairs(InputMgr._CachedInputPowerOwner) do
        local object = power.Object
        if object and obj_util.is_valid(object) and InputMgr._InputEvents[power] then
            local fn = InputMgr._InputEvents[power][IADef] and InputMgr._InputEvents[power][IADef][TriggerEvent]
            if fn then
                if fn(object, ActionValue, ElapsedSeconds, TriggeredSeconds, InputAction) then
                    break
                end
            end
        end
    end
end

return InputMgr