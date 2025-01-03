--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--

---@type BTDecorator_NotBorn_C
local M = UnLua.Class()

function M:PerformConditionCheckAI(OwnerController, ControlledPawn)
    return not gas_util.asc_has_tag_by_name(ControlledPawn, 'Chr.State.Born')
end

return M