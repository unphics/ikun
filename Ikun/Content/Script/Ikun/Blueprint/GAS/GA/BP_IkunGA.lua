--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--

---@class BP_IkunGA
local M = UnLua.Class()

function M:GAFail()
    self.Result = false
    self:K2_EndAbility()
end

function M:GASuccess()
    self.Result = true
    self:K2_EndAbility()
end

return M