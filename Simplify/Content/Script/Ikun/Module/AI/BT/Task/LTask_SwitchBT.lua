---
---@brief 将当前行为树切换为其他行为树执行
---@author zys
---@data Sat Apr 19 2025 06:04:16 GMT+0800 (中国标准时间)
---

---@class LTask_SwitchBT: LTask
---@field NewBTKey string
local LTask_SwitchBT = class.class 'LTask_SwitchBT' : extends 'LTask' {
    ctor = function()end,
    OnInit = function()end,
    OnUpdate = function()end,
}
function LTask_SwitchBT:ctor(NodeDispName, NewBTKey)
    class.LTask.ctor(self, NodeDispName)

    self.NewBTKey = NewBTKey
end
function LTask_SwitchBT:OnInit()
    class.LTask.OnInit(self)
end
function LTask_SwitchBT:OnUpdate(DeltaTime)
    if self.Chr and self.Chr:GetRole() then
        self:DoSwitchBT()
        self:DoTerminate(true)
        return
    end
    self:DoTerminate(false)
end
function LTask_SwitchBT:DoSwitchBT()
    local OldBT = self.Chr:GetRole().BT.Desc
    log.info('LTask_SwitchBT', OldBT, self.NewBTKey, self.Chr:PrintRoleInfo())
    self.Chr:GetRole():SwitchNewBT(self.NewBTKey)
end