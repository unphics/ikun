--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--

---@type TopMarkComp_C
local M = UnLua.Class()

-- function M:Initialize(Initializer)
-- end

function M:ReceiveBeginPlay()
    if net_util.is_server(self:GetOwner()) then
        self:GetOwner().MsgBusComp:RegEvent('RoleName', self, self.OnRoleNameChanged)
    end
end

-- function M:ReceiveEndPlay()
-- end

function M:ReceiveTick(DeltaSeconds)
    self.Overridden.ReceiveTick(self, DeltaSeconds)
    if not self:GetOwner():HasAuthority() then
        self:TopMarkFaceToPlayer()
    end
end

---@public
---@param Text string
function M:SetTextContent_RPC(Text)
    self:GetWidget().TxtName:SetText(Text)
end

function M:TopMarkFaceToPlayer()
    local PlayerPawn = UE.UGameplayStatics.GetPlayerPawn(self:GetOwner(), 0) ---@type APawn
    local Rot = UE.UKismetMathLibrary.FindLookAtRotation(self:GetOwner():K2_GetActorLocation(), PlayerPawn:K2_GetActorLocation())
    Rot.Roll = 0
    Rot.Pitch = 0
    Rot.Yaw = Rot.Yaw - self:GetOwner():K2_GetActorRotation().Yaw
    self:K2_SetRelativeRotation(Rot, false, UE.FHitResult(), false)
end

function M:OnRoleNameChanged(NewName)
    self:SetTextContent(NewName)
end

return M
