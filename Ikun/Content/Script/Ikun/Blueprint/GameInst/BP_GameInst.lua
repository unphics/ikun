--[[
    一些全局的工具在这里引用
]]
require("SharedPCH")

---@class BP_GameInst: BP_GameInst_C
local M = UnLua.Class()

function M:ReceiveInit()
    self.Overridden.ReceiveInit(self)
    -- 此处是客户端和服务器最早启动的地方, 因此可以在这里做一些初始化全局或者静态的东西
    log.log('BP_GameInstanceBase:ReceiveInit')

    -- local main = class.new "derive" ()
    -- main:test()
end

return M