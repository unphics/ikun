
---
---@brief   注册Location的场景对象到逻辑对象
---@author  zys
---@data    Sat Oct 04 2025 13:57:22 GMT+0800 (中国标准时间)
---

---@class BP_LocationRegisterComp: BP_LocationRegisterComp_C
local BP_LocationRegisterComp = UnLua.Class()

---@override
function BP_LocationRegisterComp:ReceiveBeginPlay()
    if net_util.is_server(self) then
        gameinit.registerinit(gameinit.ring.init_loc, self, self.AvatarInitLocation)
    end
end

---@private [Init]
function BP_LocationRegisterComp:AvatarInitLocation()
    if self.LocationId <= 0 then
        log.error('BP_LocationRegisterComp:AvatarInitLocation()', '未配置LocationId')
        return
    end
    local house = class.new'LocationClass'() ---@as LocationClass
    house:InitByLocationAvatar(self.LocationId, self:GetOwner())
end

return BP_LocationRegisterComp