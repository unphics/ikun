--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--

---@type UIGameMaster_C
local M = UnLua.Class()

local make_gm_cmd = function(name, fn, close)
    local cmd = {}
    cmd.Name = name
    cmd.Fn = fn
    cmd.Close = close
    return cmd
end

local GMTab = {"默认"}

local GMCmd = {}
GMCmd[1] = {
    make_gm_cmd("测试指令", function ()
        log.warn("测试指令")
    end, true),
    make_gm_cmd("动画调试", function()
        ui_util.uimgr:OpenUI(ui_util.uidef.UIInfo.AnimDebug)
    end, true)
}

--function M:Initialize(Initializer)
--end

--function M:PreConstruct(IsDesignTime)
--end

function M:Construct()
    self.TabIndex = 1

    local tbTab = {}
    for i, tab in ipairs(GMTab) do
        local item = {}
        item.Name = tab
        item.Index = i
        item.OwnerUI = self
        table.insert(tbTab, item)
    end
    ui_util.set_list_items(self.ListTab, tbTab)

    self:UpdateCmdPanel()
end

--function M:Tick(MyGeometry, InDeltaTime)
--end

function M:SelectCurTab(Index)
    self.TabIndex = Index
    self:UpdateCmdPanel()
end

function M:UpdateCmdPanel()
    local tb = GMCmd[self.TabIndex]
    if tb then
        local tbCmd = {}
        for i, ele in ipairs(tb) do
            table.insert(tbCmd, ele)
        end
        ui_util.set_list_items(self.TileCmd, tbCmd)
    end
end

return M
