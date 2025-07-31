
---
---@brief   入战组件
---@author  zys
---@data    Thu Jul 31 2025 23:32:46 GMT+0800 (中国标准时间)
---

local OutFightTime = 5 -- 出战时间

---@class InFightComp: InFightComp_C
local InFightComp = UnLua.Class()

-- function InFightComp:Initialize(Initializer)
-- end

function InFightComp:ReceiveBeginPlay()
    self.OutFightTimeCount = nil
end

-- function InFightComp:ReceiveEndPlay()
-- end

function InFightComp:ReceiveTick(DeltaSeconds)
    if net_util.is_client(self) then
        return
    end
    if self.OutFightTimeCount then
        self.OutFightTimeCount = self.OutFightTimeCount - DeltaSeconds
        if self.OutFightTimeCount < 0 then
            gas_util.asc_remove_tag_by_name(self:GetOwner(), 'Role.State.InFight')
            self.OutFightTimeCount = nil
        end
    end
end

---@private 入战调用
function InFightComp:C2S_FallInFight_RPC()
    if not self:CheckInFight() then
        gas_util.asc_add_tag_by_name(self:GetOwner(), 'Role.State.InFight')
        self.OutFightTimeCount = OutFightTime
    end
end

---@public is chr in fight
function InFightComp:CheckInFight()
    return gas_util.asc_has_tag_by_name(self:GetOwner(), 'Role.State.InFight')
end

return InFightComp