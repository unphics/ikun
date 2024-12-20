---
---@brief 国家
---@author zys
---@data Sat Dec 21 2024 00:51:53 GMT+0800 (中国标准时间)
---

---@class Kingdom : MdBase
---@field tbZone Zone[] 这个国家的所有大区/行省
---@field tbRole Role[] 这个国家的所有角色
---@field Name string
local Kingdom = class.class"Kingdom" : extends 'MdBase'{
--[[public]]
    ctor = function(Name) end,
    Init = function() end,
    Tick = function() end,
    AddSettlement = function(Settlement) end,
    FindSettlementLua = function(Id) end,
    AddKingdomMember = function()end,
--[[private]]
    tbZone = nil,
    Name = nil,
    tbRole = nil,
}
---@param Name string
function Kingdom:ctor(Name)
    self.tbRole = {}
    self.tbZone = {}
    local zone = class.new "Zone" ("default")
    table.insert(self.tbZone, zone)
    self.Name = Name
end
function Kingdom:AddSettlement(Settlement)
    self.tbZone[1]:AddSettlement(Settlement)
end
---@param SettlementId number
---@return Settlement
function Kingdom:FindSettlementLua(SettlementId)
    for _, zone in ipairs(self.tbZone) do
        for j, settlement in ipairs(zone.tbSettlement) do
            if j == SettlementId then
                return settlement
            end
        end
    end
end
---@param Role Role
function Kingdom:AddKingdomMember(Role)
    table.insert(self.tbRole, Role)
end
function Kingdom:Tick(DeltaTime)
    for i, Role in ipairs(self.tbRole) do
        Role:Tick(DeltaTime)
    end
end