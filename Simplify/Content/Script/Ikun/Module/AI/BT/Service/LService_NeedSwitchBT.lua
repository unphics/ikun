
---
---@brief 同步检测需要切换行为树
---@author zys
---@data Fri Apr 25 2025 21:21:44 GMT+0800 (中国标准时间)
---

---@class LService_NeedSwitchBT: LService
local LService_NeedSwitchBT = class.class 'LService_NeedSwitchBT' : extends 'LService' {
    OnUpdate = function()end,
}
function LService_NeedSwitchBT:OnUpdate(DeltaTime)
    local NewBTKey = self.Blackboard:GetBBValue('BBNewBTKey')
    if NewBTKey then
        self:DoSwitchBT(NewBTKey)
        self:DoTerminate(true)
    end
end
function LService_NeedSwitchBT:DoSwitchBT(NewBTKey)
    local OldBT = self.Chr:GetRole().BT.Desc
    log.log('LTask_SwitchBT', OldBT, NewBTKey, self.Chr:PrintRoleInfo())
    self.Chr:GetRole():SwitchNewBT(NewBTKey)
    self.Blackboard:SetBBValue('BBNewBTKey', nil)
end