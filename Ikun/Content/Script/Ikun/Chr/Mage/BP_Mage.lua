
---
---@brief   法师
---@author  zys
---@data    Sun Sep 14 2025 14:39:28 GMT+0800 (中国标准时间)
---

local NavPathData = require("System/Move/NavPathData") ---@type NavPathData

---@class BP_Mage: BP_ChrBase
local BP_Mage = UnLua.Class('Ikun/Chr/Blueprint/BP_ChrBase')

function BP_Mage:ReceiveBeginPlay()
    self.Overridden.ReceiveBeginPlay(self)
end

function BP_Mage:C2S_LeftStart_RPC()
    self.SkillComp:TryActiveSlotSkill('NormalOne')
end

function BP_Mage:qqq()
    local nav = NavPathData.GenNavPathData(self, self:K2_GetActorLocation(), UE.FVector(0,0,0), nil, function(n)
        while not n:IsNavFinished() do
            log.dev('qqq',n:GetCurSegEnd())
            n:AdvanceSeg()
        end
    end)
end

return BP_Mage