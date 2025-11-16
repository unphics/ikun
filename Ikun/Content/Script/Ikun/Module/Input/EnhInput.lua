
---
---@brief   增强输入的应用层
---@author  zys
---@data    Sat Jul 19 2025 17:05:58 GMT+0800 (中国标准时间)
---

local EnhancedInput = require("UnLua.EnhancedInput")

local IMCDef = require('System/Input/IMCDef') ---@type IMCDef
local IADef = require('System/Input/IADef') ---@type IADef
local TriggerEventDef = require('System/Input/TriggerEventDef') ---@type TriggerEventDef

local InputMgr = require('Ikun/Module/Input/InputMgr')

---@class EnhInput
---@field _EnhInputSubsys UEnhancedInputLocalPlayerSubsystem
---@field _PlayerController PC_Base
local EnhInput = {}

EnhInput.IADef = IADef
EnhInput.IMCDef = IMCDef
EnhInput.TriggerEventDef = TriggerEventDef

---@public [Init]
---@param PC BP_IkunPC
EnhInput.InitByPlayerController = function(PC)
    log.info('增强输入', 'EnhInput.InitByPlayerController', PC)
    EnhInput._PlayerController = PC
    EnhInput._GetEnhInputSubsys()
end

---@public [IMC]
EnhInput.AddIMC = function(IMC)
    local sys = EnhInput._GetEnhInputSubsys()
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
    if EnhInput._GetEnhInputSubsys() and EnhInput.HasIMC(IMC) then
        EnhInput._GetEnhInputSubsys():RemoveMappingContext(IMC, UE.FModifyContextOptions())
    end
end

---@public [IMC]
EnhInput.HasIMC = function(IMC)
    if EnhInput._GetEnhInputSubsys() then
        return EnhInput._GetEnhInputSubsys():HasMappingContext(IMC)
    end
end

---@public [Tool]
---@return UEnhancedInputLocalPlayerSubsystem
EnhInput._GetEnhInputSubsys = function()
    if not EnhInput._EnhInputSubsys then
        EnhInput._EnhInputSubsys  = UE.USubsystemBlueprintLibrary.GetLocalPlayerSubSystemFromPlayerController(EnhInput._PlayerController, UE.UEnhancedInputLocalPlayerSubsystem)
    end
    return EnhInput._EnhInputSubsys
end

---@public
EnhInput.BindActions = function(pc)
    log.info(log.key.ueinit, 'EnhInput.BindActions running')
    EnhancedInput.BindAction(pc, IADef.IA_Move, EnhInput.TriggerEventDef.Triggered,
        function(SourceObj, ActionValue, ElapsedSeconds, TriggeredSeconds, InputAction)
            InputMgr.TriggerInputAction(IADef.IA_Move, EnhInput.TriggerEventDef.Triggered, ActionValue, ElapsedSeconds, TriggeredSeconds, InputAction)
        end)
    EnhancedInput.BindAction(pc, IADef.IA_Look, EnhInput.TriggerEventDef.Triggered,
        function(SourceObj, ActionValue, ElapsedSeconds, TriggeredSeconds, InputAction)
            InputMgr.TriggerInputAction(IADef.IA_Look, EnhInput.TriggerEventDef.Triggered, ActionValue, ElapsedSeconds, TriggeredSeconds, InputAction)
        end)
    EnhancedInput.BindAction(pc, IADef.IA_MouseLeftDown, EnhInput.TriggerEventDef.Started,
        function(SourceObj, ActionValue, ElapsedSeconds, TriggeredSeconds, InputAction)
            InputMgr.TriggerInputAction(IADef.IA_MouseLeftDown, EnhInput.TriggerEventDef.Started, ActionValue, ElapsedSeconds, TriggeredSeconds, InputAction)
        end)
    EnhancedInput.BindAction(pc, IADef.IA_MouseLeftDown, EnhInput.TriggerEventDef.Completed,
        function(SourceObj, ActionValue, ElapsedSeconds, TriggeredSeconds, InputAction)
            InputMgr.TriggerInputAction(IADef.IA_MouseLeftDown, EnhInput.TriggerEventDef.Completed, ActionValue, ElapsedSeconds, TriggeredSeconds, InputAction)
        end)
    EnhancedInput.BindAction(pc, IADef.IA_MouseLeftDown, EnhInput.TriggerEventDef.Triggered,
        function(SourceObj, ActionValue, ElapsedSeconds, TriggeredSeconds, InputAction)
            InputMgr.TriggerInputAction(IADef.IA_MouseLeftDown,EnhInput.TriggerEventDef.Triggered, ActionValue, ElapsedSeconds, TriggeredSeconds, InputAction)
        end)
    EnhancedInput.BindAction(pc, IADef.IA_BlankSpace, EnhInput.TriggerEventDef.Started,
        function(SourceObj, ActionValue, ElapsedSeconds, TriggeredSeconds, InputAction)
            InputMgr.TriggerInputAction(IADef.IA_BlankSpace,EnhInput.TriggerEventDef.Started, ActionValue, ElapsedSeconds, TriggeredSeconds, InputAction)
        end, _)

    EnhancedInput.BindAction(pc, IADef.IA_Interact, EnhInput.TriggerEventDef.Started,
        function(SourceObj, ActionValue, ElapsedSeconds, TriggeredSeconds, InputAction)
            InputMgr.TriggerInputAction(IADef.IA_Interact,EnhInput.TriggerEventDef.Started, ActionValue, ElapsedSeconds, TriggeredSeconds, InputAction)
        end, _)
    EnhancedInput.BindAction(pc, IADef.IA_Wheel, EnhInput.TriggerEventDef.Started,
        function(SourceObj, ActionValue, ElapsedSeconds, TriggeredSeconds, InputAction)
            InputMgr.TriggerInputAction(IADef.IA_Wheel,EnhInput.TriggerEventDef.Started, ActionValue, ElapsedSeconds, TriggeredSeconds, InputAction)
        end, _)
    EnhancedInput.BindAction(pc, IADef.IA_Tab, EnhInput.TriggerEventDef.Started,
        function(SourceObj, ActionValue, ElapsedSeconds, TriggeredSeconds, InputAction)
            InputMgr.TriggerInputAction(IADef.IA_Tab,EnhInput.TriggerEventDef.Started, ActionValue, ElapsedSeconds, TriggeredSeconds, InputAction)
        end, _)

    EnhancedInput.BindAction(pc, IADef.IA_Bag, EnhInput.TriggerEventDef.Completed,
        function(SourceObj, ActionValue, ElapsedSeconds, TriggeredSeconds, InputAction)
            InputMgr.TriggerInputAction(IADef.IA_Bag, EnhInput.TriggerEventDef.Completed, ActionValue, ElapsedSeconds, TriggeredSeconds, InputAction)
        end, _)

    EnhancedInput.BindAction(pc, IADef.IA_Equip, EnhInput.TriggerEventDef.Completed,
        function(SourceObj, ActionValue, ElapsedSeconds, TriggeredSeconds, InputAction)
            InputMgr.TriggerInputAction(IADef.IA_Equip, EnhInput.TriggerEventDef.Completed, ActionValue, ElapsedSeconds, TriggeredSeconds, InputAction)
        end, _)
end

return EnhInput