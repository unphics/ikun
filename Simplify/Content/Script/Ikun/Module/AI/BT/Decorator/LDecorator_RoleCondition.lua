
---@class LDecorator_RoleCondition: LDecorator
---@field CondFnName string
local LDecorator_RoleCondition = class.class 'LDecorator_RoleCondition' : extends 'LDecorator' {
--[[private]]
    CondFnName = nil,
}
function LDecorator_RoleCondition:ctor(NodeDispName, CondFnName)
    class.LDecorator.ctor(self, NodeDispName)
    self.CondFnName = CondFnName
end
function LDecorator_RoleCondition:Judge()
    if not self.Chr then
        return false
    end
    local Role = self.Chr.RoleComp.Role
    if not Role then
        return false
    end
    if (not Role[self.CondFnName]) or (type(Role[self.CondFnName]) ~= 'function') then
        return false
    end
    local Result = Role[self.CondFnName](Role)
    return Result
end