
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

---@class LocationClass: MdBase
---@field _LocationId number
---@field _Name string
---@field _OwnerRoles RoleClass[]
local LocationClass = class.class 'LocationClass' {
    ctor = function()end,
    InitByLocationId = function()end,
    GetBelongSettlement = function()end,
    _OwnerRoles = nil,
    _LocationId = nil,
    _Name = nil,
}

---@override
function LocationClass:ctor()
    self._OwnerRoles = {}
end

---@public [Init]
function LocationClass:InitByLocationId(LocationId)
    local allLocationConfig = MdMgr.ConfigMgr:GetConfig('Location')
    local locationConfig = allLocationConfig[self._LocationId] ---@type LocationConfig
    if not locationConfig then
        log.error('LocationClass:InitByLocationId() ', self._LocationId)
        return
    end

    self._LocationId = LocationId
    self._Name = locationConfig.LocationName
    log.info(log.key.sceneinit, 'InitByLocationId()', self._Name, self._LocationId)

    ---@todo zys Location的所属Landform

    local settlement = self:GetBelongSettlement()
    settlement:AddLocation(self)
end

---@private [Pure]
---@return SettlementBaseClass
function LocationClass:GetBelongSettlement()
    local allLocationConfig = MdMgr.ConfigMgr:GetConfig('Location')
    local locationConfig = allLocationConfig[self._LocationId] ---@type LocationConfig
    local settlementId = locationConfig.BelongSettlement
    local districtMgr = MdMgr.Cosmos:GetStar().DistrictMgr
    local settlement = districtMgr:FindOrCreateSettlement(settlementId)
    return settlement
end

return LocationClass