
---
---@brief   Role组件, 作为游戏世界的一员, 需要此组件初始化数据
---@author  zys
---@data    Sun Jan 19 2025 20:19:40 GMT+0800 (中国标准时间)
---

---@class RoleComp: RoleComp_C
---@field Role RoleClass
local RoleComp = UnLua.Class()

---@protected [ImplBP]
function RoleComp:ReceiveBeginPlay()
    if net_util.is_server(self:GetOwner()) then    
        gameinit.registerinit(gameinit.ring.three, self, self.AvatarInitRole)
    end
end

---@private [Server] [Init] 初始化逻辑角色
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

    -- 对于行为树, 如果有用户自定义, 则使用自定义的初始化行为树
    if self.CustomStartBT then
        self.Role:SwitchNewBT(self.StartBTKey)
    end
end

---@public [Debug]
function RoleComp:LogBT2UI_RPC(Text)
    if not ui_util.uimgr or not ui_util.uidef then
        return
    end
    local MainHud = ui_util.uimgr:GetUI(ui_util.uidef.MainHud)
    if not MainHud then
        return
    end
    MainHud.TxtLog:SetText(Text)
end

return RoleComp