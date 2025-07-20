
---
---@author  zys
---@data    Sun Jul 20 2025 12:27:04 GMT+0800 (中国标准时间)
---

---@class ABP_Archer: ABP_Archer_C
---@field Chr BP_ChrBase
local ABP_Archer = UnLua.Class()

-- function ABP_Archer:Initialize(Initializer)
-- end

-- function ABP_Archer:BlueprintInitializeAnimation()
-- end

---@override
function ABP_Archer:BlueprintBeginPlay()
    if self:TryGetPawnOwner().GetRole then
        self.Chr = self:TryGetPawnOwner()
    end
end

---@override
function ABP_Archer:BlueprintUpdateAnimation(DeltaTimeX)
    self:UpdateFightInfo()
end

-- function ABP_Archer:BlueprintPostEvaluateAnimation()
-- end

function ABP_Archer:UpdateFightInfo()
    if not self.Chr then
        return
    end
    self.bInFight = gas_util.asc_has_tag_by_name(self.Chr, 'Role.State.InFight')
end

return ABP_Archer