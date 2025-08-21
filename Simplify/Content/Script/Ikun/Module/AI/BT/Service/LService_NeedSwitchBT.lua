
---
---@brief 同步检测需要切换行为树
---@author zys
---@data Fri Apr 25 2025 21:21:44 GMT+0800 (中国标准时间)
---

local BBKeyDef = require("Ikun.Module.AI.BT.BBKeyDef")

---@class LService_NeedSwitchBT: LService
local LService_NeedSwitchBT = class.class 'LService_NeedSwitchBT' : extends 'LService' {
    OnUpdate = function()end,
}
function LService_NeedSwitchBT:OnUpdate(DeltaTime)
    local NewBTKey = self.Blackboard:GetBBValue(BBKeyDef.BBNewBTKey)
    if NewBTKey then
        self:DoSwitchBT(NewBTKey)
        self:DoTerminate(true)
    end
end
function LService_NeedSwitchBT:DoSwitchBT(NewBTKey)
    local OldBT = self.Chr:GetRole().BT.Desc
    log.info('LTask_SwitchBT', OldBT, NewBTKey, self.Chr:PrintRoleInfo())
    self.Blackboard:SetBBValue(BBKeyDef.BBNewBTKey, nil)
    self.Chr:GetRole():SwitchNewBT(NewBTKey)
end