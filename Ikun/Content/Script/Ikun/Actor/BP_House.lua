local GameInit = require("GameInit")

---
---@brief   房子
---@author  zys
---@data    Mon Sep 22 2025 22:16:52 GMT+0800 (中国标准时间)
---

---@class BP_House: AActor
local BP_House = UnLua.Class()

---@override
function BP_House:ReceiveBeginPlay()
    if net_util.is_server(self) then
        gameinit.registerinit(gameinit.ring.one, self, self.AvatarInitLocation)
    end
end

---@private [Init]
function BP_House:AvatarInitLocation()
    if not self.LocationId then
        log.error('BP_House:InitHouse()', '未配置LocationId')
        return
    end
    local house = class.new'LocationClass'() ---@type LocationClass
    house:InitByLocationId(self.LocationId)
end

return BP_House