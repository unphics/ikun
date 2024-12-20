---
---@brief Npc组件, 该Chr若以Npc运行, 则需要此组件初始化数据
---

local RoleConfig = require('Content/Role/Config/RoleConfig')

---@type NpcComp_C
local M = UnLua.Class()

-- function M:Initialize(Initializer)
-- end

function M:ReceiveBeginPlay()
    self:GetOwner().MsgBusComp:RegEvent('ChrInitData', self, function() self:OnChrInitData() end)
    self:GetOwner().MsgBusComp:RegEvent('ChrInitDisplay', self, function() self:ChrInitDisplay() end)
end

-- function M:ReceiveEndPlay()
-- end

-- function M:ReceiveTick(DeltaSeconds)
-- end

function M:OnChrInitData()
    if net_util.is_client() or (not self.bNpc) then
        return false
    end
    self.Role = class.new 'Role'()
    self.Role:InitByAvatar(self:GetOwner(), self.RoleConfigId, self.bNpc)
end

function M:ChrInitDisplay()
    if net_util.is_client(self:GetOwner()) or (not self.bNpc) then
        return
    end
    self:GetOwner().MsgBusComp:TriggerEvent('RoleName', self.Role:GetDisplayName())
end

function M:LogBT2UI_RPC(Text)
    if not ui_util.uimgr then
        return
    end
    local MainHud = ui_util.uimgr:GetUIInst(ui_util.uidef.UIInfo.MainHud)
    if not MainHud then
        return
    end
    MainHud.TxtLog:SetText(Text)
end

return M
