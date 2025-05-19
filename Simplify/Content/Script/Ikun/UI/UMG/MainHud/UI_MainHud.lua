
---
---@brief 主界面
---@author zys
---@data Sat Apr 05 2025 15:27:02 GMT+0800 (中国标准时间)
---

---@class UI_MainHud: UI_MainHud_C
local M = UnLua.Class()

--function M:Initialize(Initializer)
--end

--function M:PreConstruct(IsDesignTime)
--end

function M:Construct()
    local bSvr = net_util.is_server()
    self.TxtLocalHost:SetText(bSvr and 'LocalHost=Server' or 'LocalHost=Client')

    local tb = {}

    for i = 1, 20 do
        table.insert(tb, {a = 1})
    end
    
    ui_util.set_list_items(self.ListView_93, tb)
    -- self.ListView_93:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
    
end

--function M:Tick(MyGeometry, InDeltaTime)
--end

return M
