--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--

local OutFightTime = 5 -- 出战时间

---@class InFightComp: InFightComp_C
local M = UnLua.Class()

-- function M:Initialize(Initializer)
-- end

function M:ReceiveBeginPlay()
    self.OutFightTimeCount = nil
end

-- function M:ReceiveEndPlay()
-- end

function M:ReceiveTick(DeltaSeconds)
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

function M:C2S_FallInFight_RPC()
    if not gas_util.asc_has_tag_by_name(self:GetOwner(), 'Role.State.InFight') then
        gas_util.asc_add_tag_by_name(self:GetOwner(), 'Role.State.InFight')
        self.OutFightTimeCount = OutFightTime
    end
end

return M