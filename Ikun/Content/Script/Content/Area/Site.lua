
---
---@brief   地点的小位置
---@author  zys
---@data    Mon Sep 22 2025 00:09:49 GMT+0800 (中国标准时间)
---

---@class SiteConfig
---@field SiteId integer
---@field SiteName string
---@field SiteDesc string
---@field BelongLocationId integer

---@class SiteClass
---@field _Position FVector
---@field _SiteId integer
---@field _SiteName string
---@field _BelongLocationId integer
local SiteClass = class.class 'SiteClass' {}

---@public [Init]
---@param Position FVector
---@param SiteId integer
function SiteClass:InitSite(Position, SiteId)
    local config = ConfigMgr:GetConfig('Site')[SiteId] ---@as SiteConfig
    if not config then
        log.error('无效的SiteId', SiteId)
        return
    end
    local belongLocation = Cosmos:GetStar():FindLocation(config.BelongLocationId)
    if not belongLocation then
        log.error('无效的BelongLocationId', config.BelongLocationId, SiteId, obj_util.dispname(SiteAvatar))
        return
    end
    self._SiteId = SiteId
    self._SiteName = config.SiteName
    self._BelongLocationId = config.BelongLocationId
    self._Position = UE.FVector(Position.X, Position.Y, Position.Z)

    log.info(log.key.sceneinit, 'InitSite', self._SiteName, self._SiteId, self._Position)
    
    belongLocation:RegisterSite(self)
end

---@public
---@return FVector
function SiteClass:GetSitePos()
    return self._Position
end

return SiteClass