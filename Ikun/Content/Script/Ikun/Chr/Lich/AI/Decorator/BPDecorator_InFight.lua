--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--

---@type BTDecorator_InFight_C
local M = UnLua.Class()

function M:PerformConditionCheckAI(OwnerController, ControlledPawn)
    return gas_util.asc_has_tag_by_name(ControlledPawn, 'Chr.State.InFight')
end

return M