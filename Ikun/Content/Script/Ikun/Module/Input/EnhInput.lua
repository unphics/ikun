
---
---@brief   增强输入的应用层
---@author  zys
---@data    Sat Jul 19 2025 17:05:58 GMT+0800 (中国标准时间)
---

local EnhancedInput = require("UnLua.EnhancedInput")

local InputMgr = require('Ikun/Module/Input/InputMgr')

---@class EnhInput
---@field _EnhInputSubsys UEnhancedInputLocalPlayerSubsystem
---@field _PlayerController BP_IkunPC
local EnhInput = {}

EnhInput.IMCDef = {
    IMC_Base = '/Game/Ikun/Blueprint/Input/IMC/IMC_Base.IMC_Base',
    IMC_Interact = '/Game/Ikun/UI/Input/IMC/IMC_Interact.IMC_Interact',
    IMC_Bag = '/Game/Ikun/UI/Input/IMC/IMC_Bag.IMC_Bag',
}

---@enum IADef
local IADef = {
    IA_Move = '/Game/Ikun/Blueprint/Input/IA/IA_Move.IA_Move',
    IA_Look = '/Game/Ikun/Blueprint/Input/IA/IA_Look.IA_Look',
    IA_MouseLeftDown = '/Game/Ikun/Blueprint/Input/IA/IA_MouseLeftDown.IA_MouseLeftDown',
    IA_Interact = '/Game/Ikun/UI/Input/IA/IA_Interact.IA_Interact',
    IA_Wheel = '/Game/Ikun/UI/Input/IA/IA_Wheel.IA_Wheel',
    IA_Tab = '/Game/Ikun/UI/Input/IA/IA_Tab.IA_Tab',
    IA_BlankSpace = '/Game/Ikun/Blueprint/Input/IA/IA_BlankSpace.IA_BlankSpace',
    IA_Bag = '/Game/Ikun/Blueprint/Input/IA/IA_Bag.IA_Bag',
    
}
EnhInput.IADef = IADef

---@enum TriggerEvent
EnhInput.TriggerEvent = {
    Triggered = 'Triggered',
    Started = 'Started',
    Ongoing = 'Ongoing',
    Canceled = 'Canceled',
    Completed = 'Completed',
}

---@public [Init]
---@param PC BP_IkunPC
EnhInput.InitByPlayerController = function(PC)
    log.info('增强输入', 'EnhInput.InitByPlayerController', PC)
    EnhInput._PlayerController = PC
    EnhInput._GetEnhInputSubsys()
end

---@public [IMC]
EnhInput.AddIMC = function(IMC)
    local sys = EnhInput.GetEnhInputSubsys()
    if not sys then
        log.error('EnhInput.AddIMC', '注册IMC时EnhSubSys未准备好', IMC)
        return
    end
    if EnhInput.HasIMC(IMC) then
        log.error('EnhInput.AddIMC', '重复注册IMC', IMC)
    end
    sys:AddMappingContext(IMC, 100, UE.FModifyContextOptions())
end

---@public [IMC]
EnhInput.RemoveIMC = function(IMC)
    if EnhInput.GetEnhInputSubsys() and EnhInput.HasIMC(IMC) then
        EnhInput.GetEnhInputSubsys():RemoveMappingContext(IMC, UE.FModifyContextOptions())
    end
end

---@public [IMC]
EnhInput.HasIMC = function(IMC)
    if EnhInput.GetEnhInputSubsys() then
        return EnhInput.GetEnhInputSubsys():HasMappingContext(IMC)
    end
end

---@public [Tool]
---@return UEnhancedInputLocalPlayerSubsystem
EnhInput.GetEnhInputSubsys = function()
    if not EnhInput._EnhInputSubsys then
        EnhInput._GetEnhInputSubsys()
    end
    return EnhInput._EnhInputSubsys
end

---@private [Tool]
EnhInput._GetEnhInputSubsys = function()
    EnhInput._EnhInputSubsys  = UE.USubsystemBlueprintLibrary.GetLocalPlayerSubSystemFromPlayerController(EnhInput._PlayerController, UE.UEnhancedInputLocalPlayerSubsystem)
end

---@public
EnhInput.BindActions = function(pc)
    log.info(log.key.ueinit, 'EnhInput.BindActions running')
    EnhancedInput.BindAction(pc, EnhInput.IADef.IA_Move, EnhInput.TriggerEvent.Triggered,
        function(SourceObj, ActionValue, ElapsedSeconds, TriggeredSeconds, InputAction)
            InputMgr.TriggerInputAction(IADef.IA_Move, EnhInput.TriggerEvent.Triggered, ActionValue, ElapsedSeconds, TriggeredSeconds, InputAction)
        end)
    EnhancedInput.BindAction(pc, EnhInput.IADef.IA_Look, EnhInput.TriggerEvent.Triggered,
        function(SourceObj, ActionValue, ElapsedSeconds, TriggeredSeconds, InputAction)
            InputMgr.TriggerInputAction(IADef.IA_Look, EnhInput.TriggerEvent.Triggered, ActionValue, ElapsedSeconds, TriggeredSeconds, InputAction)
        end)
    EnhancedInput.BindAction(pc, EnhInput.IADef.IA_MouseLeftDown, EnhInput.TriggerEvent.Started,
        function(SourceObj, ActionValue, ElapsedSeconds, TriggeredSeconds, InputAction)
            InputMgr.TriggerInputAction(IADef.IA_MouseLeftDown, EnhInput.TriggerEvent.Started, ActionValue, ElapsedSeconds, TriggeredSeconds, InputAction)
        end)
    EnhancedInput.BindAction(pc, EnhInput.IADef.IA_MouseLeftDown, EnhInput.TriggerEvent.Completed,
        function(SourceObj, ActionValue, ElapsedSeconds, TriggeredSeconds, InputAction)
            InputMgr.TriggerInputAction(IADef.IA_MouseLeftDown, EnhInput.TriggerEvent.Completed, ActionValue, ElapsedSeconds, TriggeredSeconds, InputAction)
        end)
    EnhancedInput.BindAction(pc, EnhInput.IADef.IA_MouseLeftDown, EnhInput.TriggerEvent.Triggered,
        function(SourceObj, ActionValue, ElapsedSeconds, TriggeredSeconds, InputAction)
            InputMgr.TriggerInputAction(IADef.IA_MouseLeftDown,EnhInput.TriggerEvent.Triggered, ActionValue, ElapsedSeconds, TriggeredSeconds, InputAction)
        end)
    EnhancedInput.BindAction(pc, EnhInput.IADef.IA_BlankSpace, EnhInput.TriggerEvent.Started,
        function(SourceObj, ActionValue, ElapsedSeconds, TriggeredSeconds, InputAction)
            InputMgr.TriggerInputAction(IADef.IA_BlankSpace,EnhInput.TriggerEvent.Started, ActionValue, ElapsedSeconds, TriggeredSeconds, InputAction)
        end, _)

    EnhancedInput.BindAction(pc, EnhInput.IADef.IA_Interact, EnhInput.TriggerEvent.Started,
        function(SourceObj, ActionValue, ElapsedSeconds, TriggeredSeconds, InputAction)
            InputMgr.TriggerInputAction(IADef.IA_Interact,EnhInput.TriggerEvent.Started, ActionValue, ElapsedSeconds, TriggeredSeconds, InputAction)
        end, _)
    EnhancedInput.BindAction(pc, EnhInput.IADef.IA_Wheel, EnhInput.TriggerEvent.Started,
        function(SourceObj, ActionValue, ElapsedSeconds, TriggeredSeconds, InputAction)
            InputMgr.TriggerInputAction(IADef.IA_Wheel,EnhInput.TriggerEvent.Started, ActionValue, ElapsedSeconds, TriggeredSeconds, InputAction)
        end, _)
    EnhancedInput.BindAction(pc, EnhInput.IADef.IA_Tab, EnhInput.TriggerEvent.Started,
        function(SourceObj, ActionValue, ElapsedSeconds, TriggeredSeconds, InputAction)
            InputMgr.TriggerInputAction(IADef.IA_Tab,EnhInput.TriggerEvent.Started, ActionValue, ElapsedSeconds, TriggeredSeconds, InputAction)
        end, _)

    EnhancedInput.BindAction(pc, EnhInput.IADef.IA_Bag, EnhInput.TriggerEvent.Completed,
        function(SourceObj, ActionValue, ElapsedSeconds, TriggeredSeconds, InputAction)
            InputMgr.TriggerInputAction(IADef.IA_Bag, EnhInput.TriggerEvent.Completed, ActionValue, ElapsedSeconds, TriggeredSeconds, InputAction)
        end, _)
end

return EnhInput