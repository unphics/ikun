
---
---@brief   客户端全局输入管理
---@author  zys
---@data    Sat Jul 19 2025 20:53:10 GMT+0800 (中国标准时间)
---

---@class InputPower
---@field Object UObject
---@field bBorrowInput boolean

---@class InputMgr
---@field _InputEvents table<UObject, table<IADef, fun(UObject, ActionValue, ElapsedSeconds, TriggeredSeconds, InputAction): boolean>>
---@field _InputPowerStack InputPower[]
---@field _CachedInputPowerOwner UObject[]
local InputMgr = {}

InputMgr._InputEvents = {}
InputMgr._InputPowerStack = {}
InputMgr._CachedInputPowerOwner = {}

---@public 获取输入监听权
InputMgr.ObtainInputPower = function(Object)
    for _, item in ipairs(InputMgr._InputPowerStack) do
        if item.Object == Object then
            return log.error('InputMgr.ObtainInputPower() 重复获取所有权')
        end
    end
    local item = {} ---@type InputPower
    item.Object = Object
    item.bBorrowInput = false
    table.insert(InputMgr._InputPowerStack, item)
    InputMgr._RefreshCachedInputPowerOwner()
end

---@public 借出输入监听权
InputMgr.BorrowInputPower = function(Object)
    for _, item in ipairs(InputMgr._InputPowerStack) do
        if item.Object == Object then
            return log.error('InputMgr.BorrowInputPower() 重复获取所有权')
        end
    end
    local item = {} ---@type InputPower
    item.Object = Object
    item.bBorrowInput = true
    table.insert(InputMgr._InputPowerStack, item)
    InputMgr._RefreshCachedInputPowerOwner()
end

---@public 放弃输入监听权
InputMgr.ReliquishInputPower = function(Object)
    for i, item in ipairs(InputMgr._InputPowerStack) do
        if item.Object == Object then
            table.remove(InputMgr._InputPowerStack, i)
            break
        end
    end
    InputMgr._RefreshCachedInputPowerOwner()
end

---@private 刷新缓存的当前所有权拥有者
InputMgr._RefreshCachedInputPowerOwner = function()
    InputMgr._CachedInputPowerOwner = {}
    for i = #InputMgr._InputPowerStack, 1, -1 do
        local inputPower = InputMgr._InputPowerStack[i] ---@type InputPower
        table.insert(InputMgr._CachedInputPowerOwner, inputPower.Object)
        if not inputPower.bBorrowInput then
            break
        end
    end
end

---@public 注册监听输入事件
---@param Object UObject
---@param IADef IADef
---@param fn fun(UObject, ActionValue, ElapsedSeconds, TriggeredSeconds, InputAction): boolean
InputMgr.RegisterInputAction = function(Object, IADef, fn)
    if not InputMgr._InputEvents[Object] then
        InputMgr._InputEvents[Object] = {}
    end
    if InputMgr._InputEvents[Object][IADef] then
        return log.error('InputMgr.RegisterInputAction() 重复的IA事件监听')
    end
    InputMgr._InputEvents[Object][IADef] = fn
end

---@public 反注册监听输入
---@param Object UObject
InputMgr.UnregisterInputAction = function(Object)
    InputMgr._InputEvents[Object] = nil
end

---@public 触发输入事件
---@param IADef IADef
InputMgr.TriggerInputAction = function(IADef, ActionValue, ElapsedSeconds, TriggeredSeconds, InputAction)
    for _, object in ipairs(InputMgr._CachedInputPowerOwner) do
        if object and obj_util.is_valid(object) then
            local fn = InputMgr._InputEvents[object][IADef]
            if fn then
                if fn(object, ActionValue, ElapsedSeconds, TriggeredSeconds, InputAction) then
                    break
                end
            end
        end
    end
end

return InputMgr