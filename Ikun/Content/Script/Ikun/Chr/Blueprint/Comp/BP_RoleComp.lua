
---
---@brief   角色组件
---@author  zys
---@data    Sun Jan 19 2025 20:19:40 GMT+0800 (中国标准时间)
---

---@class RoleComp: RoleComp_C
---@field Role RoleClass
local RoleComp = UnLua.Class()

---@override
function RoleComp:ReceiveBeginPlay()
    if net_util.is_server(self:GetOwner()) then    
        gameinit.registerinit(gameinit.ring.three, self, self.AvatarInitRole)
    end
end

---@private [Init] 初始化逻辑角色
function RoleComp:AvatarInitRole()
    local roleConfig = RoleMgr:GetRoleConfig(self.RoleConfigId)
    if not roleConfig then
        log.error('RoleComp:AvatarInitRole()', '无效的RoleConfigId')
        return
    end

    -- 如果有特化的角色模板则使用特化初始化
    if roleConfig.SpecialClass then
        self.Role = class.new(roleConfig.SpecialClass)() ---@as RoleClass
    else
        self.Role = class.new 'RoleClass'() ---@as RoleClass
    end

    self.Role:InitByAvatar(self:GetOwner(), self.RoleConfigId, self.bNpc)
end

return RoleComp