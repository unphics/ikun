
---
---@brief   角色持有的地点
---@todo    name: HoldLocation -> RoleLocation
---@author  zys
---@data    Tue Sep 23 2025 01:03:41 GMT+0800 (中国标准时间)
---

---@class RoleHoldLocationClass
---@field _OwnerRole RoleBaseClass
---@field _tbHoldLocation LocationClass[]
local RoleHoldLocationClass = class.class 'RoleHoldLocationClass' {
    ctor = function()end,
    GetHomeLocation = function()end,
    _OwnerRole = nil,
    _tbHoldLocation = nil,
}

---@override
---@param InOwnerRole RoleBaseClass
function RoleHoldLocationClass:ctor(InOwnerRole, InConfigId)
    self._tbHoldLocation = {}
    self._OwnerRole = InOwnerRole

    local config = RoleMgr:GetRoleConfig(InConfigId) ---@type RoleConfig
    if config.HoldLocations then
        local star = Cosmos:GetStar()
        for _, locationId in ipairs(config.HoldLocations) do
            local location = star:FindLocation(locationId)
            if location then
                table.insert(self._tbHoldLocation, location)
                log.info('角色获得Location', self._OwnerRole:RoleName(),locationId)
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

---@public 取到柜台
---@return SiteClass?, LocationClass?
function RoleHoldLocationClass:GetCounter()
    ---@param Site SiteClass
    ---@return boolean
    local isCounter = function(Site)
        -- 临时处理
        if Site._SiteId == 661006 then
            return true
        end
        return false
    end
    for _, location in ipairs(self._tbHoldLocation) do
        local sites = location:GetAllSites()
        for _, site in ipairs(sites) do
            if isCounter(site) then
                return site, location
            end
        end
    end
    return nil, nil
end

return RoleHoldLocationClass