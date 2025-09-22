
---
---@brief   角色持有的地点
---@author  zys
---@data    Tue Sep 23 2025 01:03:41 GMT+0800 (中国标准时间)
---

---@class RoleHoldLocationClass
---@field _OwnerRole RoleClass
---@field _tbHoldLocation LocationClass[]
local RoleHoldLocationClass = class.class 'RoleHoldLocationClass' {
    ctor = function()end,
    _OwnerRole = nil,
    _tbHoldLocation = nil,
}

---@override
---@param OwnerRole RoleClass
function RoleHoldLocationClass:ctor(OwnerRole, ConfigId)
    self._tbHoldLocation = {}
    
    self._OwnerRole = OwnerRole

    local config = MdMgr.RoleMgr:GetRoleConfig(ConfigId) ---@type RoleConfig
    local star = MdMgr.Cosmos:GetStar()
    if config.HoldLocations then
        for _, locationId in ipairs(config.HoldLocations) do
            local location = star:FindLocation(locationId)
            if location then
                table.insert(self._tbHoldLocation, location)
                log.dev('qqqqqqq', OwnerRole:GetRoleDispName(), location._Name)
            end
        end
    end
end

---@public
---@todo zys 这里的Location要分类
---@return LocationClass?
function RoleHoldLocationClass:GetHomeLocation()
    return self._tbHoldLocation[1]
end

return RoleHoldLocationClass