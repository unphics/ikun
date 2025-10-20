
---
---@brief   入战组件
---@author  zys
---@data    Thu Jul 31 2025 23:32:46 GMT+0800 (中国标准时间)
---

---@class InFightComp: InFightComp_C
---@field private _OutFightTimeCount number
local InFightComp = UnLua.Class()

---@override
function InFightComp:ReceiveBeginPlay()
    self._OutFightTimeCount = nil
end

---@override
function InFightComp:ReceiveTick(DeltaSeconds)
    if net_util.is_client(self) then
        return
    end
    if self._OutFightTimeCount then
        self._OutFightTimeCount = self._OutFightTimeCount - DeltaSeconds
        if self._OutFightTimeCount < 0 then
            self:C2S_ExitFight()
        end
    end
end

---@public [Server] 入战调用
function InFightComp:EnterFight()
    self._OutFightTimeCount = ConfigMgr:GetGlobalConst('OutFightTime')
    if not self:CheckInFight() then
        gas_util.add_loose_tag(self:GetOwner(), 'Role.State.InFight')
    end
end

---@public [Server] 出战调用
function InFightComp:ExitFight()
    if self:CheckInFight() then
        self._OutFightTimeCount = nil
        gas_util.remove_loose_tag(self:GetOwner(), 'Role.State.InFight')
    end
end

---@public 装备武器
function InFightComp:C2S_Equip_RPC()
    if not self:CheckIsEquip() then
        gas_util.add_loose_tag(self:GetOwner(), 'Role.State.bEquip')
        self:GetOwner().SkillComp:TryActiveSlotSkill('Equip')
    end
end

---@public 收起武器
function InFightComp:C2S_UnEquip_RPC()
    if self:CheckIsEquip() then
        gas_util.remove_loose_tag(self:GetOwner(), 'Role.State.bEquip')
        self:GetOwner().SkillComp:TryActiveSlotSkill('UnEquip')
    end
end

---@public 当前拿起了武器
---@return boolean
function InFightComp:CheckIsEquip()
    local bResult = gas_util.has_loose_tag(self:GetOwner(), 'Role.State.bEquip')
    return bResult
end

---@public 当前是否在战斗状态
---@return boolean
function InFightComp:CheckInFight()
    local bResult = gas_util.has_loose_tag(self:GetOwner(), 'Role.State.InFight')
    return bResult
end

return InFightComp