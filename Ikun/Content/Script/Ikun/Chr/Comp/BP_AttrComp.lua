--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--

---@type AttrComp_C
local M = UnLua.Class()

-- function M:Initialize(Initializer)
-- end

function M:ReceiveBeginPlay()
    self.Overridden.ReceiveBeginPlay(self)

    if not self:GetOwner():HasAuthority() then
        local ASC = self:GetOwner():GetAbilitySystemComponent()
        local AttrSet = ASC:GetAttributeSet(UE.UIkunAttrSet)
        local HealthProp = AttrSet.GetAttribute('Health')
        ---@type UAbilityAsync_WaitAttributeChanged
        local HealthChanged = UE.UAbilityAsync_WaitAttributeChanged.WaitForAttributeChanged(self:GetOwner(), HealthProp, false)
        HealthChanged.Changed:Add(self, self.OnHealthChanged)
        HealthChanged:Activate()
    end
end

-- function M:ReceiveEndPlay()
-- end

-- function M:ReceiveTick(DeltaSeconds)
-- end

function M:OnHealthChanged(Attr, NewVal, OldVal)
    self:SetUIHealthValue(NewVal / 100)
end

function M:SetUIHealthValue(num)
    ui_util.mainhud:SetHealth(num)
end

return M
