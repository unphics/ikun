---
---@brief 战斗角色, Role的成员
---@author zys
---@data Thu Apr 10 2025 22:56:22 GMT+0800 (中国标准时间)
---@desc 
---@todo FightCareer后面放在Blackboard中逐渐放弃FightCareerClass
---

local FightCareerDef = require('Content/Role/FightCareerDef')

---@class FightCareerClass
---@field OwnerRole RoleClass
---@field tbFightCareerAssign FightCareerDef[]
local FightCareerClass = class.class 'FightCareerClass'{
--[[public]]
    ctor = function()end,
    Init = function()end,
--[[private]]
    OwnerRole = nil,
    tbFightCareerAssign = nil,
}
function FightCareerClass:ctor(OwnerRole)
    self.OwnerRole = OwnerRole
    self.tbFightCareerAssign = {}
    if not self.OwnerRole then
        log.error('FightCareerClass:ctor() Failed to index valid OwnerRole')
    end
end
function FightCareerClass:Init(FightCareerAssign)
    if FightCareerAssign then
        for _, ele in ipairs(FightCareerAssign) do 
            table.insert(self.tbFightCareerAssign, ele)
        end
    end
end

return FightCareerClass