
---
---@brief   摊位
---@author  zys
---@data    Fri Oct 03 2025 12:46:36 GMT+0800 (中国标准时间)
---

---@class BP_Stall: BP_Stall_C
local BP_Stall = UnLua.Class()

---@override
function BP_Stall:ReceiveBeginPlay()
    if net_util.is_server(self) then
        gameinit.registerinit(gameinit.ring.one, self, self.AvatarInitLocation)
    end
end

---@private [Init]
function BP_Stall:AvatarInitLocation()
    if not self.LocationId then
        log.error('BP_Stall:AvatarInitLocation()', '未配置LocationId')
        return
    end
    local house = class.new'LocationClass'() ---@as LocationClass
    house:InitByLocationAvatar(self.LocationId, self)
end

return BP_Stall