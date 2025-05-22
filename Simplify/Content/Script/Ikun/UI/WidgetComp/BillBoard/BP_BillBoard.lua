---
---@brief 
---@author zys
---@data Sat Apr 05 2025 18:36:20 GMT+0800 (中国标准时间)
---

---@class BP_BillBoardComp: BP_BillBoardComp_C
---@field BillboardContent table<string, string>
local M = UnLua.Class()

-- function M:Initialize(Initializer)
-- end

function M:ReceiveBeginPlay()
    self:GetOwner().MsgBusComp:RegEvent('RoleName', self, self.OnRoleNameUpdate)
    self.BillboardContent = {}
end

-- function M:ReceiveEndPlay()
-- end

function M:ReceiveTick(DeltaSeconds)
    self:Face2Player()
    self:OnTick()
end

---@public [Client] [Server] 直接设置Billboard文本
function M:Multicast_SetText_RPC(Text)
    self:GetWidget().TxtDebug:SetText(Text)
end

---@private [Tick] Billboard永远面向玩家
function M:Face2Player()
    local PlayerPawn = UE.UGameplayStatics.GetPlayerPawn(self:GetOwner(), 0) ---@type APawn
    if not PlayerPawn then
        return
    end
    local Rot = UE.UKismetMathLibrary.FindLookAtRotation(self:GetOwner():K2_GetActorLocation(), PlayerPawn:K2_GetActorLocation())
    Rot.Roll = 0
    Rot.Pitch = 0
    Rot.Yaw = Rot.Yaw - self:GetOwner():K2_GetActorRotation().Yaw
    self:K2_SetRelativeRotation(Rot, false, UE.FHitResult(), false)
end

---@private [Init]
function M:OnRoleNameUpdate(RoleName)
    -- self:Multicast_SetText(RoleName .. '\n' .. self:GetOwner():GetRole().RoleInstId)

    -- debug
    -- self.BillboardContent.RoleName = RoleName
    self.BillboardContent.RoleInstId = self:GetOwner():GetRole().RoleInstId
    self:RefreshBillboardShowText()
end
---@private [Tick]
function M:OnTick()
    if not net_util.is_server() then
        return
    end
    local Role = self:GetOwner():GetRole() ---@type RoleClass
    if Role and Role.debug_bt then
        self.BillboardContent.debug_bt = 'DebugBT_DebugBT'
    end
end

---@private [Debug]
function M:RefreshBillboardShowText()
    local str = ''
    for key, text in pairs(self.BillboardContent) do
        str = str .. text .. '\n'
    end
    self:Multicast_SetText(str)
end
---@public [Debug]
function M:UpdateFightPos()
    local Role = self:GetOwner():GetRole() ---@type RoleClass
    -- self.BillboardContent.FightPos = Role.FightPos
end

return M
