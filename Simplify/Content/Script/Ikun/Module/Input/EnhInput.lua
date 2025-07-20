
---
---@brief   增强输入的应用层
---@author  zys
---@data    Sat Jul 19 2025 17:05:58 GMT+0800 (中国标准时间)
---

local EnhancedInput = require("UnLua.EnhancedInput")

---@class EnhInput
---@field _EnhInputSubsys UEnhancedInputLocalPlayerSubsystem
---@field PlayerController BP_IkunPC
---@field _InputEvents table<IADef, table<UObject, fun(PC, ActionValue, ElapsedSeconds, TriggeredSeconds, InputAction)>>
local EnhInput = {}

EnhInput._InputEvents = {}

EnhInput.IMCDef = {
    IMC_Base = '/Game/Ikun/Blueprint/Input/IMC/IMC_Base.IMC_Base',
}

---@enum IADef
local IADef = {
    IA_Move = '/Game/Ikun/Blueprint/Input/IA/IA_Move.IA_Move',
    IA_Look = '/Game/Ikun/Blueprint/Input/IA/IA_Look.IA_Look',
    IA_MouseLeftDown = '/Game/Ikun/Blueprint/Input/IA/IA_MouseLeftDown.IA_MouseLeftDown',
}
EnhInput.IADef = IADef

EnhInput.TriggerEvent = {
    Triggered = 'Triggered',
    Started = 'Started',
    Ongoing = 'Ongoing',
    Canceled = 'Canceled',
    Completed = 'Completed',
}

---@public
---@param PC BP_IkunPC
EnhInput.InitByPlayerController = function(PC)
    EnhInput.PlayerController = PC
    EnhInput._GetEnhInputSubsys()
end

---@public
EnhInput.AddIMC = function(IMC)
    local sys = EnhInput.GetEnhInputSubsys()
    if sys and not EnhInput.HasIMC(IMC) then
        sys:AddMappingContext(IMC, 100, UE.FModifyContextOptions())
    end
end

---@public
EnhInput.RemoveIMC = function(IMC)
    if EnhInput.GetEnhInputSubsys() and EnhInput.HasIMC(IMC) then
        EnhInput.GetEnhInputSubsys():RemoveMappingContext(IMC, UE.FModifyContextOptions())
    end
end

---@public
EnhInput.HasIMC = function(IMC)
    if EnhInput.GetEnhInputSubsys() then
        return EnhInput.GetEnhInputSubsys():HasMappingContext(IMC)
    end
end

---@public
---@return UEnhancedInputLocalPlayerSubsystem
EnhInput.GetEnhInputSubsys = function()
    if not EnhInput._EnhInputSubsys then
        EnhInput._GetEnhInputSubsys()
    end
    return EnhInput._EnhInputSubsys
end

---@private
EnhInput._GetEnhInputSubsys = function()
    EnhInput._EnhInputSubsys  = UE.USubsystemBlueprintLibrary.GetLocalPlayerSubSystemFromPlayerController(EnhInput.PlayerController, UE.UEnhancedInputLocalPlayerSubsystem)
end

---@public
---@param IADef IADef
---@param Object UObject
---@param fn fun(PC, ActionValue, ElapsedSeconds, TriggeredSeconds, InputAction)
EnhInput.RegisterInputAction = function(IADef, Object, fn)
    EnhInput._InputEvents[IADef] = {[Object] = fn}
end

---@public
EnhInput.BindActions = function(pc)
    log.log(log.key.ueinit, 'EnhInput.BindActions running')
    EnhancedInput.BindAction(pc, EnhInput.IADef.IA_Move, EnhInput.TriggerEvent.Triggered,
        function(SourceObj, ActionValue, ElapsedSeconds, TriggeredSeconds, InputAction)
            local event = EnhInput._InputEvents[EnhInput.IADef.IA_Move]
            if event then
                for o, fn in pairs(event) do
                    fn(o, ActionValue, ElapsedSeconds, TriggeredSeconds, InputAction)
                end
            end
        end)
    EnhancedInput.BindAction(pc, EnhInput.IADef.IA_Look, EnhInput.TriggerEvent.Triggered,
        function(SourceObj, ActionValue, ElapsedSeconds, TriggeredSeconds, InputAction)
            local event = EnhInput._InputEvents[EnhInput.IADef.IA_Look]
            if event then
                for o, fn in pairs(event) do
                    fn(o, ActionValue, ElapsedSeconds, TriggeredSeconds, InputAction)
                end
            end
        end)
    EnhancedInput.BindAction(pc, EnhInput.IADef.IA_MouseLeftDown, EnhInput.TriggerEvent.Started,
        function(SourceObj, ActionValue, ElapsedSeconds, TriggeredSeconds, InputAction)
            local event = EnhInput._InputEvents[EnhInput.IADef.IA_MouseLeftDown]
            if event then
                for o, fn in pairs(event) do
                    fn(o, ActionValue, ElapsedSeconds, TriggeredSeconds, InputAction)
                end
            end
        end)
    
end

return EnhInput