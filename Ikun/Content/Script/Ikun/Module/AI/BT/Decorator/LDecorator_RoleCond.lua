
---@class LDecorator_RoleCond: LDecorator
---@field CondFnName string
local LDecorator_RoleCond = class.class 'LDecorator_RoleCond' : extends 'LDecorator' {
    CondFnName = nil,
}
function LDecorator_RoleCond:ctor(DisplayName, CondFnName)
    class.LDecorator.ctor(self, DisplayName)
    self.CondFnName = CondFnName
end
function LDecorator_RoleCond:Judge()
    if not self.Chr then
        return false
    end
    local Role = self.Chr.NpcComp.Role
    if not Role then
        return false
    end
    if (not Role[self.CondFnName]) or (type(Role[self.CondFnName]) ~= 'function') then
        return false
    end
    local Result = Role[self.CondFnName](Role)
    return Result
end