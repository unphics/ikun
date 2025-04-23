
---
---@brief 全体成员等待切树
---@author zys
---@data Wed Apr 23 2025 20:18:13 GMT+0800 (中国标准时间)
---

local ELStatus = require('Ikun/Module/AI/BT/ELStatus')

---@class LTask_TeamWaitSwitchBT : LTask
---@field CurTime number
local LTask_TeamWaitSwitchBT = class.class 'LTask_TeamWaitSwitchBT' : extends 'LTask' {
    CurTime = nil,
}
function LTask_TeamWaitSwitchBT:ctor(DispName)
    class.LTask.ctor(self, DispName)
end
function LTask_TeamWaitSwitchBT:OnInit()
    class.LTask.OnInit(self)
    self.CurTime = 0
end
function LTask_TeamWaitSwitchBT:OnUpdate(DeltaTime)
    self.CurTime = self.CurTime + DeltaTime
    local NewBTKey = self.Blackboard:GetBBValue('TeamNewBTKey')
    if NewBTKey then
        self:DoSwitchBT(NewBTKey)
        self:DoTerminate(true)
    end
end
function LTask_TeamWaitSwitchBT:OnTerminate()
    class.LTask.OnTerminate(self)
end
function LTask_TeamWaitSwitchBT:DoSwitchBT(NewBTKey)
    local OldBT = self.Chr:GetRole().BT.Desc
    log.log('LTask_SwitchBT', OldBT, NewBTKey, self.Chr:PrintRoleInfo())
    self.Chr:GetRole():SwitchNewBT(NewBTKey)
end
function LTask_TeamWaitSwitchBT:PrintNode(nDeep)
    local Text = ''
    if nDeep > 0 then
        for i = 1, nDeep do
            Text = Text .. '        '
        end
    end
    local CurTime = self.CurTime and string.format('%02.1f', self.CurTime) or 'nil'
    Text = string.format('%sTask : %s-%s : %s\n', Text, self.DisplayName, CurTime,ELStatus.PrintLStatus(self.LastStatus))
    return Text
end
return LTask_TeamWaitSwitchBT