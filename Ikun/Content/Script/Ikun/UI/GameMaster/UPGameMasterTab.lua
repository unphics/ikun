--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--

---@type UPGameMasterTab_C
local M = UnLua.Class()

--function M:Initialize(Initializer)
--end

--function M:PreConstruct(IsDesignTime)
--end

function M:Construct()
    self.Button.OnClicked:Add(self, self.OnButtonClicked)
    
end

--function M:Tick(MyGeometry, InDeltaTime)
--end

function M:OnListItemObjectSet(In)
    self.ItemData = In.Value
    self.TxtName:SetText(In.Value.Name)
end

function M:OnButtonClicked()
    self.ItemData.OwnerUI:SelectCurTab(self.ItemData.Index)
end

return M
