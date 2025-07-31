
---
---@brief   增强输入的应用层
---@author  zys
---@data    Sat Jul 19 2025 17:05:58 GMT+0800 (中国标准时间)
---

local EnhancedInput = require("UnLua.EnhancedInput")

local InputMgr = require('Ikun/Module/Input/InputMgr')

---@class EnhInput
---@field _EnhInputSubsys UEnhancedInputLocalPlayerSubsystem
---@field PlayerController BP_IkunPC
local EnhInput = {}

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

---@public [Init]
---@param PC BP_IkunPC
EnhInput.InitByPlayerController = function(PC)
    EnhInput.PlayerController = PC
    EnhInput._GetEnhInputSubsys()
end

---@public [IMC]
EnhInput.AddIMC = function(IMC)
    local sys = EnhInput.GetEnhInputSubsys()
    if sys and not EnhInput.HasIMC(IMC) then
        sys:AddMappingContext(IMC, 100, UE.FModifyContextOptions())
    end
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
    EnhInput._EnhInputSubsys  = UE.USubsystemBlueprintLibrary.GetLocalPlayerSubSystemFromPlayerController(EnhInput.PlayerController, UE.UEnhancedInputLocalPlayerSubsystem)
end

---@public
EnhInput.BindActions = function(pc)
    log.info(log.key.ueinit, 'EnhInput.BindActions running')
    EnhancedInput.BindAction(pc, EnhInput.IADef.IA_Move, EnhInput.TriggerEvent.Triggered,
        function(SourceObj, ActionValue, ElapsedSeconds, TriggeredSeconds, InputAction)
            InputMgr.TriggerInputAction(IADef.IA_Move, ActionValue, ElapsedSeconds, TriggeredSeconds, InputAction)
        end)
    EnhancedInput.BindAction(pc, EnhInput.IADef.IA_Look, EnhInput.TriggerEvent.Triggered,
        function(SourceObj, ActionValue, ElapsedSeconds, TriggeredSeconds, InputAction)
            InputMgr.TriggerInputAction(IADef.IA_Look, ActionValue, ElapsedSeconds, TriggeredSeconds, InputAction)
        end)
    EnhancedInput.BindAction(pc, EnhInput.IADef.IA_MouseLeftDown, EnhInput.TriggerEvent.Started,
        function(SourceObj, ActionValue, ElapsedSeconds, TriggeredSeconds, InputAction)
            InputMgr.TriggerInputAction(IADef.IA_MouseLeftDown, ActionValue, ElapsedSeconds, TriggeredSeconds, InputAction)
        end)
end

return EnhInput