
---
---@brief   增强输入的应用层
---@author  zys
---@data    Sat Jul 19 2025 17:05:58 GMT+0800 (中国标准时间)
---

local EnhancedInput = require("UnLua.EnhancedInput")

---@class EnhInput
---@field _EnhInputSubsys UEnhancedInputLocalPlayerSubsystem
---@field PlayerController BP_IkunPC
local EnhInput = {}

EnhInput.IMCDef = {
    IMC_Move = '/Game/Ikun/Blueprint/Input/IMC/IMC_Move.IMC_Move',
}

EnhInput.IADef = {
    IA_Move = '/Game/Ikun/Blueprint/Input/IA/IA_Move.IA_Move',
}

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
EnhInput.BindMove = function(pc)
    log.dev(log.key.ueinit, 'EnhInput.BindMove running')
    EnhancedInput.BindAction(pc, EnhInput.IADef.IA_Move, EnhInput.TriggerEvent.Started,
        function(SourceObj, ActionValue, ElapsedSeconds, TriggeredSeconds, InputAction)
            local pc = SourceObj ---@type BP_IkunPC
            log.dev('EnhInput.BindMove', ActionValue)
            local rot = pc:GetControlRotation()
            local yawRot = UE.FRotator(0, rot.Yaw, 0)
            local forward = yawRot:GetForwardVector()
            pc:qqq()
            if pc.OwnerChr then
                -- pc.OwnerChr:MoveForwardBack(forward, ActionValue.Y)
                -- pc.OwnerChr:MoveRightLeft(forward, ActionValue.X)
            end
        end)
end

return EnhInput