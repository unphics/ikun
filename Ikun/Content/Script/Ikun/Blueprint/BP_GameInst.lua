
---
---@brief   GameInstance,一些全局的东西在这里引用
---@author  zys
---@data    Fri May 30 2025 22:37:34 GMT+0800 (中国标准时间)
---

require('Start')
require('Bootstrapper')

---@class BP_GameInst: BP_GameInst_C
local BP_GameInst = UnLua.Class()

function BP_GameInst:ReceiveInit()
    self.Overridden.ReceiveInit(self)
    -- 此处是客户端和服务器最早启动的地方, 因此可以在这里做一些初始化全局或者静态的东西
    log.info(log.key.ueinit..' BP_GameInstanceBase:ReceiveInit'..'--------------------------------------------------------------------------')

    UE.UKismetSystemLibrary.ExecuteConsoleCommand(self, 't.MaxFPS 1000', nil)
    UE.UKismetSystemLibrary.ExecuteConsoleCommand(self, 'stat FPS', nil)
end

function BP_GameInst:ReceiveOnWorldChanged(OldWorld, NewWorld)
    do
        local newWorldName = NewWorld and NewWorld:GetName()
        local type = NewWorld and UE.UIkunFnLib.GetWorldType(NewWorld)
        log.info('BP_GameInst:ReceiveOnWorldChanged()', OldWorld, NewWorld, newWorldName, type)
    end
end

return BP_GameInst