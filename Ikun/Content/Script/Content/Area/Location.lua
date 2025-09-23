
---
---@brief   地点
---@author  zys
---@data    Mon Sep 22 2025 22:34:33 GMT+0800 (中国标准时间)
---

---@class LocationConfig
---@field LocationId number
---@field LocationName string
---@field LocationDesc string
---@field BelongLandform number
---@field BelongSettlement number

---@class LocationClass
---@field LocationAvatar AActor
---@field _LocationId number
---@field _Name string
---@field _OwnerRoles RoleClass[]
local LocationClass = class.class 'LocationClass' {
    ctor = function()end,
    InitByLocationAvatar = function()end,
    GetBelongSettlement = function()end,
    _OwnerRoles = nil,
    _LocationId = nil,
    _Name = nil,
}

---@public
function LocationClass:ctor()
    self._OwnerRoles = {}
end

---@public [Init]
function LocationClass:InitByLocationAvatar(LocationId, LocationAvatar)
    local allLocationConfig = ConfigMgr:GetConfig('Location')
    local locationConfig = allLocationConfig[LocationId] ---@type LocationConfig
    if not locationConfig then
        log.error(log.key.sceneinit,'LocationClass:InitByLocationAvatar() ', LocationId)
        return
    end

    self._LocationId = LocationId
    self._Name = locationConfig.LocationName
    self.LocationAvatar = LocationAvatar
    log.info(log.key.sceneinit, 'InitByLocationAvatar()', self._Name, self._LocationId)

    ---@todo zys Location的所属Landform

    local settlement = self:GetBelongSettlement()
    settlement:AddLocation(self)
    Cosmos:GetStar():RegisterLocation(self)
end

---@public [Pure] 获取所属聚集地
---@return SettlementBaseClass
function LocationClass:GetBelongSettlement()
    local allLocationConfig = ConfigMgr:GetConfig('Location')
    local locationConfig = allLocationConfig[self._LocationId] ---@type LocationConfig
    local settlementId = locationConfig.BelongSettlement
    local districtMgr = Cosmos:GetStar().DistrictMgr
    local settlement = districtMgr:FindOrCreateSettlement(settlementId)
    return settlement
end

return LocationClass