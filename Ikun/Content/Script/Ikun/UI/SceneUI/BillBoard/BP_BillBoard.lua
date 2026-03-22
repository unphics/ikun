
--[[
-- -----------------------------------------------------------------------------
--  Brief       : SceneUI-Billboard的WidgetComp
--  File        : BP_BillBoard.lua
--  Author      : zhengyanshuai
--  Date        : Sat Apr 05 2025 18:36:20 GMT+0800 (中国标准时间)
--  License     : MIT License
-- -----------------------------------------------------------------------------
--  Copyright (c) 2025-2026 zhengyanshuai
-- -----------------------------------------------------------------------------
--]]

---@class BP_BillBoardComp: BP_BillBoardComp_C
---@field BillboardContent table<string, string>
local BP_BillBoardComp = UnLua.Class()

---@override
function BP_BillBoardComp:ReceiveBeginPlay()
    self.BillboardContent = {}
end

---@override
function BP_BillBoardComp:ReceiveTick(DeltaSeconds)
    if net_util.is_client(self:GetOwner()) then
        self:Face2Player()
    end
    self:_UpdateHealthBar()
end

---@public 直接设置Billboard文本
function BP_BillBoardComp:S2C_SetText_RPC(Text)
    self:GetBillBoardUI().TxtDebug:SetText(Text)
end

---@public 
function BP_BillBoardComp:S2C_ShowHealthBar_RPC(bShow)
    self:GetBillBoardUI().HealthBar:SetVisibility(bShow and UE.ESlateVisibility.SelfHitTestInvisible or UE.ESlateVisibility.Collapsed)
end

---@private [Tick] Billboard永远面向玩家
function BP_BillBoardComp:Face2Player()
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

---@private [Role]
function BP_BillBoardComp:OnRoleNameUpdate(RoleName)
    self:S2C_SetText(self:GetOwner():GetRole():GetRoleId())
end

---@private [Tick]
function BP_BillBoardComp:_UpdateHealthBar()
    if not self:GetOwner().AttrSet then
        return
    end
    local CurHealth = self:GetOwner().AttrSet:GetAttrValueByName("Health")
    local MaxHealth = self:GetOwner().AttrSet:GetAttrValueByName("MaxHealth")
    local HP = CurHealth / MaxHealth
    self:GetBillBoardUI().HealthBar:SetPercent(HP)
end

---@public
---@return UI_BillBoard_C
function BP_BillBoardComp:GetBillBoardUI()
    return self:GetWidget()
end

return BP_BillBoardComp
