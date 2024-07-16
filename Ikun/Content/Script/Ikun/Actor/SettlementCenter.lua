--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--

local CfgSettlement = require("Content.District.Config.Settlement")

---@type SettlementCenter
local M = UnLua.Class()

-- function M:Initialize(Initializer)
-- end

-- function M:UserConstructionScript()
-- end

function M:ReceiveBeginPlay()
    if self:HasAuthority() then
        self:InitSettlement()
    end
end

-- function M:ReceiveEndPlay()
-- end

-- function M:ReceiveTick(DeltaSeconds)
-- end

-- function M:ReceiveAnyDamage(Damage, DamageType, InstigatedBy, DamageCauser)
-- end

-- function M:ReceiveActorBeginOverlap(OtherActor)
-- end

-- function M:ReceiveActorEndOverlap(OtherActor)
-- end

function M:InitSettlement()
    -- register settlement ue entity to content module
    local SettlementLua = MdMgr.tbMd.ConMgr.tbCon.AreaMgr:GetStar().DistrictMgr:GetKingdom(CfgSettlement[self.SettlementId].Kingdom):FindSettlementLua(self.SettlementId)
    SettlementLua.Actor = self
    log.warn("zys SettlementLua.SettlementName", SettlementLua.SettlementName)
    self:SetTopMarkName(SettlementLua.SettlementName)
end

function M:SetTopMarkName_Milticast(Name)
    -- todo last
    self.WidgetComp:GetWidget().TxtName:SetText(Name)
    log.warn("zys set top mark", self:HasAuthority())
end

return M