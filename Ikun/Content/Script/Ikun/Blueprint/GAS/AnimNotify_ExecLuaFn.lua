--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--

local UnLuaClass = require("Core/UnLua/Class")
local log = require("Core/Log/log")

---@type AnimNotify_ExecLuaFn_C
local M = UnLuaClass()

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