
---
---@brief   法师
---@author  zys
---@data    Sun Sep 14 2025 14:39:28 GMT+0800 (中国标准时间)
---

---@class BP_Mage: BP_ChrBase
local BP_Mage = UnLua.Class('Ikun/Chr/Blueprint/BP_ChrBase')

function BP_Mage:C2S_LeftStart_RPC()
    self.SkillComp:TryActiveSkillByTag(UE.UIkunFnLib.RequestGameplayTag('Skill.Type.Trigger.Normal'))
end

return BP_Mage