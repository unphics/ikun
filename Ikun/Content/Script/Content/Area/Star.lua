
---
---@brief   星球
---@author  zys
---@data    Tue Sep 23 2025 00:44:02 GMT+0800 (中国标准时间)
---

require("Content.District.DistrictMgr")

---@class StarClass: MdBase
---@field DistrictMgr DistrictMgr
---@field StarName string 星球的名字
---@field StarId number 星球的Id
---@field _tbLocationRef table<number, LocationClass>
local StarClass = class.class "StarClass": extends 'MdBase' {
    ctor = function()end,
    Init = function()end,
    Tick = function()end,
    RegisterLocation = function()end,
    FindLocation = function()end,
    StarId = nil,
    StarName = nil,
    DistrictMgr = nil,
    _tbLocationRef = nil,
}

---@override
function StarClass:ctor(Id, Name)
    self._tbLocationRef = {}
    
    self.StarId = Id
    self.StarName = Name
    self.DistrictMgr = class.new "DistrictMgr" (self)
end

---@override
function StarClass:Init()
end

---@override
function StarClass:Tick(DeltaTime)
    self.DistrictMgr:Tick(DeltaTime)
end

---@public 注册地点, 场景初始化相关
---@param Location LocationClass
function StarClass:RegisterLocation(Location)
    self._tbLocationRef[Location._LocationId] = Location
end

---@public 查找地点
---@return LocationClass
function StarClass:FindLocation(LocationId)
    local location = self._tbLocationRef[LocationId]
    if not location then
        log.fatal('StarClass:FindLocation()', '不存在的Location', LocationId)
        return
    end
    return location
end

return StarClass