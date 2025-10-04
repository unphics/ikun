
---
---@brief   场景编辑用, 注册site到运行时的数据表
---@author  zys
---@data    Sat Oct 04 2025 13:24:46 GMT+0800 (中国标准时间)
---

---@class BP_SiteRegisterComp: BP_SiteRegisterComp_C
local BP_SiteRegisterComp = UnLua.Class()

---@override
function BP_SiteRegisterComp:ReceiveBeginPlay()
    if net_util.is_server(self) then
        gameinit.registerinit(gameinit.ring.two, self, self.AvatarInitSite)
    end
end

---@private
function BP_SiteRegisterComp:AvatarInitSite()
    local site = class.new'SiteClass'() ---@as SiteClass
    site:InitSite(self:K2_GetComponentToWorld().Translation, self.SiteId)
    self:K2_DestroyComponent(self)
end

return BP_SiteRegisterComp