---
---@brief Role组件, 作为游戏世界的一员, 需要此组件初始化数据
---@author zys
---@data Sun Jan 19 2025 20:19:40 GMT+0800 (中国标准时间)
---

---@class RoleComp: RoleComp_C
local M = UnLua.Class()

-- function M:Initialize(Initializer)
-- end

---@protected [ImplBP]
function M:ReceiveBeginPlay()
    self:GetOwner().MsgBusComp:RegEvent('ChrInitData', self, self.OnChrInitData)
    self:GetOwner().MsgBusComp:RegEvent('ChrInitDisplay', self, self.OnChrInitDisplay)
end

-- function M:ReceiveEndPlay()
-- end

-- function M:ReceiveTick(DeltaSeconds)
-- end

---@private [Server] [Init]
function M:OnChrInitData()
    if (net_util.is_client(self:GetOwner())) then
        return false
    end
    local roleConfig = MdMgr.RoleMgr:GetRoleConfig(self.RoleConfigId)
    ---@step 如果有特化的角色模板则使用特化初始化
    if roleConfig.SpecialClass then
        self.Role = class.new(roleConfig.SpecialClass)()
    else
        self.Role = class.new 'RoleClass'()
    end
    self.Role:InitByAvatar(self:GetOwner(), self.RoleConfigId, self.bNpc)

    ---@step 对于行为树, 如果有用户自定义, 则使用自定义的初始化行为树
    if self.CustomStartBT then
        self.Role:SwitchNewBT(self.StartBTKey)
    end
end

function M:OnChrInitDisplay()
    if net_util.is_client(self:GetOwner()) or (not self.bNpc) then
        return
    end
    self:GetOwner().MsgBusComp:TriggerEvent('RoleName', self.Role:GetRoleDispName())
end

function M:LogBT2UI_RPC(Text)
    if not ui_util.uimgr or not ui_util.uidef then
        return
    end
    local MainHud = ui_util.uimgr:GetUI(ui_util.uidef.MainHud)
    if not MainHud then
        return
    end
    MainHud.TxtLog:SetText(Text)
end

return M