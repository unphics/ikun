
---
---@brief 装饰器, 团队Conditon
---@author zys
---@data Tue Apr 15 2025 02:02:46 GMT+0800 (中国标准时间)
---

---@class LDecorator_TeamCondition : LDecorator
---@field TeamConditionFnName string
local LDecorator_TeamCondition = class.class 'LDecorator_TeamCondition' : extends 'LDecorator' {
--[[private]]
    TeamConditionFnName = nil,
}
function LDecorator_TeamCondition:ctor (NodeDispName, TeamConditionFnName)
    class.LDecorator.ctor(self, NodeDispName)
    self.TeamConditionFnName = TeamConditionFnName
end
function LDecorator_TeamCondition:Judge()
    if not self.Chr then
        return false
    end
    local Role = self.Chr:GetRole()
    if not Role or not Role.Team then
        return false
    end
    if (not Role.Team[self.CondFnName]) or (type(Role.Team[self.CondFnName]) ~= 'function') then
        return false
    end
    local Result = Role.Team[self.CondFnName](Role.Team)
    return Result
end