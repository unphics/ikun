--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--

local UnLuaClass = require("Core/UnLua/Class")

---@class UP_BuffInst: UP_BuffInst_C
local UP_BuffInst = UnLuaClass()

function UP_BuffInst:Construct()
end

--function UP_BuffInst:Tick(MyGeometry, InDeltaTime)
--end

---@override
function UP_BuffInst:OnListItemObjectSet(ListItemObject)
end

---@override
function UP_BuffInst:BP_OnEntryReleased()
end

return UP_BuffInst