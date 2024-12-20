---
---@brief 人类聚集地Actor
---

local CfgSettlement = require("Content.District.Config.Settlement")

---@class SettlementCenter
local M = UnLua.Class()

function M:ReceiveBeginPlay()
    self.Overridden.ReceiveBeginPlay(self)
    if self:HasAuthority() then
        async_util.delay(self, 2, self.InitSettlement, self)
    end
end

-- function M:ReceiveEndPlay()
-- end

function M:ReceiveTick(DeltaSeconds)
    if not self:HasAuthority() then
        self:ToplogoFaceToPlayer()
    end
end

---@private [server] 初始化人类聚集地
function M:InitSettlement()
    -- register settlement ue entity to content module
    local SettlementConfig = CfgSettlement[self.SettlementId]
    local DistrictMgr = MdMgr.tbMd.ConMgr.tbCon.AreaMgr:GetStar().DistrictMgr ---@type DistrictMgr
    local Kingdom = DistrictMgr:GetKingdom(SettlementConfig.BelongKingdom) ---@type Kingdom
    local SettlementLua = Kingdom:FindSettlementLua(self.SettlementId)
    SettlementLua.Actor = self
    self:SetTopMarkName(SettlementLua.SettlementName)
end

---@private [multicast] 把聚集地名称写在toplogo上
function M:SetTopMarkName_RPC(Name)
    self.WidgetComp:GetWidget().TxtName:SetText(Name)
end

---@private [Client]
function M:ToplogoFaceToPlayer()
    ---@type APawn
    local PlayerPawn = UE.UGameplayStatics.GetPlayerPawn(self, 0)
    local Rot = UE.UKismetMathLibrary.FindLookAtRotation(self:K2_GetActorLocation(), PlayerPawn:K2_GetActorLocation())
    Rot.Roll = 0
    Rot.Pitch = 0
    Rot.Yaw = Rot.Yaw - self:K2_GetActorRotation().Yaw
    self.WidgetComp:K2_SetRelativeRotation(Rot, false, UE.FHitResult(), false)
end

return M