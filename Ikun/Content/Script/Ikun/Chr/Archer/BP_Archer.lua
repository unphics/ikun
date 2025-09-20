
---
---@brief   主角-弓箭手
---@author  zys
---@data    Thu Jul 31 2025 23:26:44 GMT+0800 (中国标准时间)
---

---@class BP_Archer: BP_Archer_C
local BP_Archer = UnLua.Class('Ikun/Chr/Blueprint/BP_ChrBase')

---@override
function BP_Archer:ReceiveBeginPlay()
    self.Super.ReceiveBeginPlay(self)
end

---@override
function BP_Archer:ReceiveTick(DeltaSeconds)
    self.Super.ReceiveTick(self, DeltaSeconds)
end

---@public PC会调用此方法
---@todo 考虑其实PC不需要调用这个，而是直接执行
function BP_Archer:C2S_LeftStart_RPC()
    -- local _, handle = gas_util.get_all_active_abilities(self)
    -- local result = self.ASC:TryActivateAbility(handle[1], true)
    self.SkillComp:TryActiveSlotSkill('NormalOne')
end

return BP_Archer