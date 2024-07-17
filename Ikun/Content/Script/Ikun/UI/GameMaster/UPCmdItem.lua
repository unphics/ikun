--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--

---@type UPCmdItem_C
local M = UnLua.Class()

--function M:Initialize(Initializer)
--end

--function M:PreConstruct(IsDesignTime)
--end

function M:Construct()
    self.BtnCmd.OnClicked:Add(self, self.OnBtnCmdClicked)
end

--function M:Tick(MyGeometry, InDeltaTime)
--end

function M:OnListItemObjectSet(In)
    self.ItemData = In.Value
    self.TxtName:SetText(In.Value.Name)
end

function M:OnBtnCmdClicked()
    self.ItemData.Fn()
    if self.ItemData.Close then
        ui_util.uimgr:CloseUI(ui_util.uidef.UIInfo.GameMaster)
    end
end

return M
