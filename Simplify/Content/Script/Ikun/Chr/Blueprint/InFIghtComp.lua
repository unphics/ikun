
---
---@brief   入战组件
---@author  zys
---@data    Thu Jul 31 2025 23:32:46 GMT+0800 (中国标准时间)
---

local OUT_FIGHT_TIME = 30 -- 出战时间

---@class InFightComp: InFightComp_C
local InFightComp = UnLua.Class()

---@override
function InFightComp:ReceiveBeginPlay()
    self.OutFightTimeCount = nil
end

---@override
function InFightComp:ReceiveTick(DeltaSeconds)
    if net_util.is_client(self) then
        return
    end
    if self.OutFightTimeCount then
        self.OutFightTimeCount = self.OutFightTimeCount - DeltaSeconds
        if self.OutFightTimeCount < 0 then
            gas_util.remove_loose_tag(self:GetOwner(), 'Role.State.InFight')
            self.OutFightTimeCount = nil
            self:GetOwner().SkillComp:TryActiveSkillByTag(UE.UIkunFnLib.RequestGameplayTag('Skill.Type.Cinematic.UnEquip'))
        end
    end
end

---@public 入战调用
function InFightComp:C2S_FallInFight_RPC()
    self.OutFightTimeCount = OUT_FIGHT_TIME
    if not self:CheckInFight() then
        gas_util.add_loose_tag(self:GetOwner(), 'Role.State.InFight')
        self:GetOwner().SkillComp:TryActiveSkillByTag(UE.UIkunFnLib.RequestGameplayTag('Skill.Type.Cinematic.Equip'))
    end
end

---@public is chr in fight
function InFightComp:CheckInFight()
    local bResult = gas_util.has_loose_tag(self:GetOwner(), 'Role.State.InFight')
    -- log.dev('InFightComp:CheckInFight() ', net_util.is_server(self:GetOwner()), bResult)
    return bResult
end

return InFightComp