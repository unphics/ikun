--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--

---@type UIMainHud_C
local M = UnLua.Class()

--function M:Initialize(Initializer)
--end

--function M:PreConstruct(IsDesignTime)
--end

-- function M:Construct()
-- end

--function M:Tick(MyGeometry, InDeltaTime)
--end

function M:InitUI(Authority)
    self.TxtAuthority:SetText(Authority)
end

function M:SetHealth(num)
    self.HealthBar:SetPercent(num)
end

return M
