local EnhancedInput = require("UnLua.EnhancedInput")

local InputBind = {}

---@public
---@param BP_IkunPC BP_IkunPC
InputBind.Bind = function(BP_IkunPC)
    EnhancedInput.BindAction(BP_IkunPC, '/Game/Ikun/Blueprint/Input/IA/IA_Move.IA_Move', 'Triggered', 
        function(SourceObj, ActionValue, ElapsedSeconds, TriggeredSeconds, InputAction)
            local PC = SourceObj
            local Rot = PC:GetControlRotation()
            local YawRot = UE.FRotator(0, Rot.Yaw, 0)
            local Forward = YawRot:GetForwardVector()
            if PC.OwnerChr then
                PC.OwnerChr:MoveForwardBack(Forward, ActionValue.Y)
                PC.OwnerChr:MoveRightLeft(Forward, ActionValue.X)
            end
        end)
    EnhancedInput.BindAction(BP_IkunPC, '/Game/Ikun/Blueprint/Input/IA/IA_Look.IA_Look', 'Triggered', 
        function(SourceObj, ActionValue, ElapsedSeconds, TriggeredSeconds, InputAction)
            local PC = SourceObj
            PC:AddYawInput(ActionValue.X * 50 * UE.UGameplayStatics.GetWorldDeltaSeconds(PC))
            PC:AddPitchInput(ActionValue.Y * 50 * UE.UGameplayStatics.GetWorldDeltaSeconds(PC))
        end)
    EnhancedInput.BindAction(BP_IkunPC, '/Game/Ikun/Blueprint/Input/IA/IA_MouseL.IA_MouseL', 'Started', 
        function(SourceObj, ActionValue, ElapsedSeconds, TriggeredSeconds, InputAction)
            local PC = SourceObj
            PC:MouseLeft_Server()
        end)
    EnhancedInput.BindAction(BP_IkunPC, '/Game/Ikun/Blueprint/Input/IA/IA_Jump.IA_Jump', 'Started', 
        function(SourceObj, ActionValue, ElapsedSeconds, TriggeredSeconds, InputAction)
            local PC = SourceObj
            if PC.OwnerChr then
                PC.OwnerChr:ChrJump()
            end
        end)
    EnhancedInput.BindAction(BP_IkunPC, '/Game/Ikun/Blueprint/Input/IA/IA_Crouch.IA_Crouch', 'Started', 
        function(SourceObj, ActionValue, ElapsedSeconds, TriggeredSeconds, InputAction)
            local PC = SourceObj
            if PC.OwnerChr then
                PC.OwnerChr:ChrCrouch()
            end
        end)
    EnhancedInput.BindAction(BP_IkunPC, '/Game/Ikun/Blueprint/Input/IA/IA_Sprint.IA_Sprint', 'Started', 
        function(SourceObj, ActionValue, ElapsedSeconds, TriggeredSeconds, InputAction)
            local PC = SourceObj
            if PC.OwnerChr then
                PC.OwnerChr:ChrSprint(true)
            end
        end)
    EnhancedInput.BindAction(BP_IkunPC, '/Game/Ikun/Blueprint/Input/IA/IA_Sprint.IA_Sprint', 'Completed', 
        function(SourceObj, ActionValue, ElapsedSeconds, TriggeredSeconds, InputAction)
            local PC = SourceObj
            if PC.OwnerChr then
                PC.OwnerChr:ChrSprint(false)
            end
        end)
end



return InputBind