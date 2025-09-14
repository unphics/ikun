--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--

---@type AnimNotify_ExecLuaFn_C
local M = UnLua.Class()

function M:Received_Notify(MeshComp)
    local actor = MeshComp:GetOwner()
    local fn = actor[self.LuaFnName]
    if fn then
        fn(actor)
    else
        log.error('Received_Notify: 找不到方法', self.LuaFnName)
    end
    ---@todo 记得看看这个return的boolean是干啥的
    return true
end

return M