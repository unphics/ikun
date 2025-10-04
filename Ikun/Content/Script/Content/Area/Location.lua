
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
---@field _Sites SiteClass[]
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
    self._Sites = {}
    self._OwnerRoles = {}
end

---@public [Init] 场景对象初始化逻辑对象
---@param LocationId integer
---@param LocationAvatar AActor
function LocationClass:InitByLocationAvatar(LocationId, LocationAvatar)
    if not LocationAvatar:IsA(UE.AActor) then
        log.dev('LocationClass:InitByLocationAvatar 状态不对', LocationId, LocationAvatar, obj_util.dispname(LocationAvatar))
        return
    end
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

---@public
---@param InSite SiteClass
function LocationClass:RegisterSite(InSite)
    for _, site in ipairs(self._Sites) do
        if site == InSite then
            return
        end
    end
    table.insert(self._Sites, InSite)
end

return LocationClass