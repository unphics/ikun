
---
---@brief   角色组件
---@author  zys
---@data    Sun Jan 19 2025 20:19:40 GMT+0800 (中国标准时间)
---

---@class BP_RoleRegisterComp: RoleComp_C
---@field Role RoleBaseClass
local BP_RoleRegisterComp = UnLua.Class()

---@override
function BP_RoleRegisterComp:ReceiveBeginPlay()
    if net_util.is_server(self:GetOwner()) then    
        gameinit.registerinit(gameinit.ring.init_role, self, self.AvatarInitRole)
    end
end

---@private [Init] 初始化逻辑角色
function BP_RoleRegisterComp:AvatarInitRole()
    if not obj_util.is_valid(self) then
        return
    end
    local role = RoleMgr:GetOrCreateRole(self.RoleConfigId)
    if role then
        local avatar = self:GetOwner()
        role:SetAvatar(avatar)
        self.Role = role
        avatar.SkillComp:InitRoleSkill()
    end
end

return BP_RoleRegisterComp