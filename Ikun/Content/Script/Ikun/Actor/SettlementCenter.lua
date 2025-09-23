
---
---@brief   人类聚集地Actor
---@author  zys
---@data    Fri Aug 22 2025 00:18:54 GMT+0800 (中国标准时间)
---

---@class SettlementCenter: SettlementCenter_C
local SettlementCenter = UnLua.Class()

---@override
function SettlementCenter:ReceiveBeginPlay()
    self.Overridden.ReceiveBeginPlay(self)

    if net_util.is_server(self) then
        async_util.delay(self, 2, self.InitSettlement, self)
    end
end

function SettlementCenter:ReceiveTick(DeltaSeconds)
end

---@private [server] 初始化人类聚集地
function SettlementCenter:InitSettlement()
    -- register settlement ue entity to content module
    local config = ConfigMgr:GetConfig('Settlement')[self.SettlementId] ---@type SettlementConfig
    if not config then
        return log.error('SettlementCenter:InitSettlement()', '无效的SettlementId', self.SettlementId)
    end
    local districtMgr = Cosmos:GetStar().DistrictMgr ---@type DistrictMgr
    local kingdom = districtMgr:FindKingdomByCfgId(config.BelongKingdomId) ---@type Kingdom
    if not kingdom then
        return log.error('SettlementCenter:InitSettlement()', '无效的BelongKingdomId', config.BelongKingdomId)
    end
    local settlement = kingdom:FindSettlementLua(self.SettlementId)
    settlement.SettlementActor = self
    self:ShowSettlementName(settlement.SettlementName)
end

---@private
---@param inName string
function SettlementCenter:ShowSettlementName(inName)
    self.BillBoardComp:S2C_SetText(inName)
    self.BillBoardComp:S2C_ShowHealthBar(false)
end

return SettlementCenter