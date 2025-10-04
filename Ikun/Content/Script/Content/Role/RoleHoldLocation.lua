
---
---@brief   角色持有的地点
---@todo    HoldLocation -> Location
---@author  zys
---@data    Tue Sep 23 2025 01:03:41 GMT+0800 (中国标准时间)
---

---@class RoleHoldLocationClass
---@field _OwnerRole RoleClass
---@field _tbHoldLocation LocationClass[]
local RoleHoldLocationClass = class.class 'RoleHoldLocationClass' {
    ctor = function()end,
    GetHomeLocation = function()end,
    _OwnerRole = nil,
    _tbHoldLocation = nil,
}

---@override
---@param OwnerRole RoleClass
function RoleHoldLocationClass:ctor(OwnerRole, ConfigId)
    self._tbHoldLocation = {}
    
    self._OwnerRole = OwnerRole

    local config = RoleMgr:GetRoleConfig(ConfigId) ---@type RoleConfig
    local star = Cosmos:GetStar()
    if config.HoldLocations then
        for _, locationId in ipairs(config.HoldLocations) do
            local location = star:FindLocation(locationId)
            if location then
                log.info('角色获得Location', self._OwnerRole:RoleName(),locationId)
                table.insert(self._tbHoldLocation, location)
            end
        end
    end
end

---@public 取到家
---@todo zys 这里的Location要分类
---@return LocationClass?
function RoleHoldLocationClass:GetHomeLocation()
    for _, location in ipairs(self._tbHoldLocation) do
        if location.LocationAvatar.GetHousePosition then
            return location
        end
    end
end

---@public 取到摊位
---@return LocationClass?
function RoleHoldLocationClass:GetStallLocation()
    for _, location in ipairs(self._tbHoldLocation) do
        if location.LocationAvatar.GetStallPosition then
            return location
        end
    end
end

---@public
---@return SettlementBaseClass?
function RoleHoldLocationClass:GetBelongSettlement()
    local home = self:GetHomeLocation()
    if not home then
        log.error('RoleHoldLocationClass:GetBelongSettlement() 无家可归')
        return
    end
    return home:GetBelongSettlement()
end

return RoleHoldLocationClass