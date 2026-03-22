
---
---@brief   村庄地图的玩家控制器
---@author  zys
---@data    Sat Nov 08 2025 00:33:58 GMT+0800 (中国标准时间)
---

local UnLuaClass = require("Core/UnLua/Class")
local log = require("Core/Log/log")
local EnhInput = require('Ikun/Module/Input/EnhInput')

---@class PC_Village: PC_Base
local PC_Village = UnLuaClass('Ikun/Blueprint/PC/PC_Base')

EnhInput.BindActions(PC_Village)

---@override
function PC_Village:ReceiveBeginPlay()
    self.Overridden.ReceiveBeginPlay(self)
    self.Super.ReceiveBeginPlay(self)
    log.info(log.key.ueinit, 'PC_Village:ReceiveBeginPlay()', net_util.print(self))
end

return PC_Village