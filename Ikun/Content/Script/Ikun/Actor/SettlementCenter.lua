---
---@brief 人类聚集地Actor
---

local CfgSettlement = require("Content.District.Config.Settlement")

---@type SettlementCenter
local M = UnLua.Class()

-- function M:Initialize(Initializer)
-- end

-- function M:UserConstructionScript()
-- end

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
        ---@note toplogo总是面向玩家
        ---@type APawn
        local PlayerPawn = UE.UGameplayStatics.GetPlayerPawn(self, 0)
        local Rot = UE.UKismetMathLibrary.FindLookAtRotation(self:K2_GetActorLocation(), PlayerPawn:K2_GetActorLocation())
        Rot.Roll = 0
        Rot.Pitch = 0
        self.WidgetComp:K2_SetRelativeRotation(Rot, false, UE.FHitResult(), false)
    end
end

---@private [server] 初始化人类聚集地
function M:InitSettlement()
    -- register settlement ue entity to content module
    local SettlementLua = MdMgr.tbMd.ConMgr.tbCon.AreaMgr:GetStar().DistrictMgr:GetKingdom(CfgSettlement[self.SettlementId].Kingdom):FindSettlementLua(self.SettlementId)
    SettlementLua.Actor = self
    self:SetTopMarkName(SettlementLua.SettlementName)
end

---@private [multicast] 把聚集地名称写在toplogo上
function M:SetTopMarkName_RPC(Name)
    self.WidgetComp:GetWidget().TxtName:SetText(Name)
end

return M