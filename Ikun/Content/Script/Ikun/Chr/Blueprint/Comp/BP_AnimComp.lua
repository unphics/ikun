
---
---@brief   AnimationComponent for Character
---@author  zys
---@data    Sun Jul 20 2025 11:01:17 GMT+0800 (中国标准时间)
---

local UnLuaClass = require("Core/Class/UnLuaClass")

---@class AnimComp: BP_AnimComp_C
local AnimComp = UnLuaClass()

---@override
function AnimComp:ReceiveBeginPlay()
    self.Overridden.ReceiveBeginPlay(self)
    self:LinkNewClassLayer('Init')
end

---@public
function AnimComp:LinkNewClassLayer(Name)
    local class = self.AnimClassLayers:Find(Name)
    if class then
        self:GetOwner().Mesh:LinkAnimClassLayers(class)
    end
end

return AnimComp