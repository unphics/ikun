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

---@private 测试SizeToContent的TextBlock的换行
local TestTextWrap = function(self, DeltaTime)end

---@public [Init] 初始化人类聚集地
M.InitSettlement = function(self)end

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
        -- TODO 可以优化
        ---@type APawn
        local PlayerPawn = UE.UGameplayStatics.GetPlayerPawn(self, 0)
        local Rot = UE.UKismetMathLibrary.FindLookAtRotation(self:K2_GetActorLocation(), PlayerPawn:K2_GetActorLocation())
        Rot.Roll = 0
        Rot.Pitch = 0
        self.WidgetComp:K2_SetRelativeRotation(Rot, false, UE.FHitResult(), false)

        -- TODO Test TopMark WidgetComp测试
        -- TestTextWrap(self, DeltaSeconds)
    end
end

-- function M:ReceiveAnyDamage(Damage, DamageType, InstigatedBy, DamageCauser)
-- end

-- function M:ReceiveActorBeginOverlap(OtherActor)
-- end

-- function M:ReceiveActorEndOverlap(OtherActor)
-- end

function M:SetTopMarkName_RPC(Name)
    self.WidgetComp:GetWidget().TxtName:SetText(Name)
end

M.InitSettlement = function(self)
    -- register settlement ue entity to content module
    local SettlementLua = MdMgr.tbMd.ConMgr.tbCon.AreaMgr:GetStar().DistrictMgr:GetKingdom(CfgSettlement[self.SettlementId].Kingdom):FindSettlementLua(self.SettlementId)
    SettlementLua.Actor = self
    self:SetTopMarkName(SettlementLua.SettlementName)
end

TestTextWrap = function(self, DeltaTime)
    if not self.count then
        self.count = 0
    end
    self.count = self.count + DeltaTime
    if self.count > 2 then
        self.count = 0
        if self.index == 0 then
            self.WidgetComp:GetWidget().TxtName:SetText("陆陆陆陆陆陆陆陆陆陆陆陆陆陆陆陆陆陆陆陆陆陆陆陆陆陆陆陆陆陆陆陆陆陆陆陆陆陆陆陆陆陆陆陆陆陆陆陆")
            self.index = 1
        elseif self.index == 1 then
            self.WidgetComp:GetWidget().TxtName:SetText("陆陆陆陆陆陆陆陆陆陆陆陆陆陆陆陆陆")
            self.index = 2
        elseif self.index == 2 then
            self.WidgetComp:GetWidget().TxtName:SetText("陆陆陆陆")
            self.index = 3
        elseif self.index == 3 then
            self.WidgetComp:GetWidget().TxtName:SetText("陆")
            self.index = 4
        else
            self.WidgetComp:GetWidget().TxtName:SetText("陆陆陆陆陆陆陆陆陆")
            self.index = 0
        end
    end
end

return M