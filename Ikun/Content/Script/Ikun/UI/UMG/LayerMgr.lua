--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--

require("Ikun.UI.UIMgr")

---@type LayerMgr_C
local M = UnLua.Class()

--function M:Initialize(Initializer)
--end

--function M:PreConstruct(IsDesignTime)
--end

function M:Construct()
    local uigmr = class.new "UIMgr" (self)
end

--function M:Tick(MyGeometry, InDeltaTime)
--end

return M
