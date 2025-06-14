
---
---@brief 获取TeamBehavior的数据到Blackboard中; 通过RoleInstId索引
---@author zys
---@data Mon May 19 2025 14:53:14 GMT+0800 (中国标准时间)
---

---@class LTask_GetTBInfo2BB: LTask
---@field ConstTableName string
---@field ConstBBKey BBKeyDef
local LTask_GetTBInfo2BB = class.class 'LTask_GetTBInfo2BB' : extends 'LTask' {
    ctor = function()end,
}
function LTask_GetTBInfo2BB:ctor(NodeDispName, TableName, BBKey)
    class.LTask.ctor(self, NodeDispName)

    self.ConstTableName = TableName
    self.ConstBBKey = BBKey
    if not TableName or not BBKey then
        log.error('LTask_GetTBInfo2BB:ctor() : 重要数据缺失')
    end
end
function LTask_GetTBInfo2BB:OnInit()
    class.LTask.OnInit(self)

    local Role = self.Chr:GetRole() ---@type RoleClass
    if not Role or not Role.Team then
        return log.error('LTask_GetTBInfo2BB:OnInit() 该Role没有Team')
    end
    local read_fn = Role.Team.CurTB['Read' .. self.ConstTableName]
    if read_fn then ---@note 如果该表有Read方法, 则优先使用Read方法读取数据
        local Role = read_fn(Role.Team.CurTB, Role:GetRoleInstId())
        self.Blackboard:SetBBValue(self.ConstBBKey, Role)
    else
        local Table = Role.Team.CurTB[self.ConstTableName]
        if not Table then
            return log.error('LTask_GetTBInfo2BB:OnInit() 该TeamBehavior没有ConstTableName成员')
        end
        self.Blackboard:SetBBValue(self.ConstBBKey, Table[Role:GetRoleInstId()])
    end
end
function LTask_GetTBInfo2BB:OnUpdate(DeltaTime)
    self:DoTerminate(true)
end