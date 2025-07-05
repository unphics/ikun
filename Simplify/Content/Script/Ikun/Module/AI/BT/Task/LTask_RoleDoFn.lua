---
---@brief RoleDoFn
---@author zys
---@data
---

---@class LTask_RoleDoFn: LTask
---@field ConstFnName string
local LTask_RoleDoFn = class.class 'LTask_RoleDoFn' : extends 'LTask' {
    ctor = function()end,
    ConstFnName = nil
}
function LTask_RoleDoFn:ctor(NodeDispName, FnName)
    class.LTask.ctor(self, NodeDispName)
    if not FnName then
        log.error("LTask_RoleDoFn:ctor(): Failed to index param FnName !")
    end
    self.ConstFnName = FnName
end
function LTask_RoleDoFn:OnInit()
    if not self.Chr then
        self:DoTerminate(false)
        return
    end
    if not self.Chr[self.ConstFnName] then
        self:DoTerminate(false)
        return
    end
    self.Chr[self.ConstFnName](self.Chr)
    self:DoTerminate(true)
end
function LTask_RoleDoFn:OnUpdate(DeltaTime)
    
end