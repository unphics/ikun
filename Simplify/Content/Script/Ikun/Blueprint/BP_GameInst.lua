---
---@brief GameInstance,一些全局的东西在这里引用
---@author zys
---@data Fri May 30 2025 22:37:34 GMT+0800 (中国标准时间)
---

require('SharedPCH')

---@class BP_GameInst: BP_GameInst_C
local M = UnLua.Class()

function M:ReceiveInit()
    self.Overridden.ReceiveInit(self)
    -- 此处是客户端和服务器最早启动的地方, 因此可以在这里做一些初始化全局或者静态的东西
    log.log(log.key.ueinit..'BP_GameInstanceBase:ReceiveInit')
    -- local main = class.new "derive" ()
    -- main:test()
end

return M