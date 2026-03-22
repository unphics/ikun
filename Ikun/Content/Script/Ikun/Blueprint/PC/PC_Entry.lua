
---
---@brief   游戏入口玩家控制器
---@author  zys
---@data    Fri Nov 07 2025 23:06:24 GMT+0800 (中国标准时间)
---

local UnLuaClass = require("Core/UnLua/Class")
local EnhInput = require('Ikun/Module/Input/EnhInput')
local log = require("Core/Log/log")

---@class PC_Entry: PC_Base
local PC_Entry = UnLuaClass('Ikun/Blueprint/PC/PC_Base')

EnhInput.BindActions(PC_Entry)

---@override
function PC_Entry:ReceiveBeginPlay()
    self.Overridden.ReceiveBeginPlay(self)
    self.Super.ReceiveBeginPlay(self)
    log.info(log.key.ueinit, 'PC_Entry:ReceiveBeginPlay()', net_util.print(self))
    self.bShowMouseCursor = true
end

return PC_Entry