
---
---@brief   AnimationComponent for Character
---@author  zys
---@data    Sun Jul 20 2025 11:01:17 GMT+0800 (中国标准时间)
---

---@class AnimComp: AnimComp_C
local AnimComp = UnLua.Class()

-- function AnimComp:Initialize(Initializer)
-- end

function AnimComp:ReceiveBeginPlay()
    self.Overridden.ReceiveBeginPlay(self)
    self:LinkNewClassLayer('Init')
end

-- function AnimComp:ReceiveEndPlay()
-- end

function AnimComp:ReceiveTick(DeltaSeconds)
end

function AnimComp:LinkNewClassLayer(Name)
    local class = self.AnimClassLayers:Find(Name)
    if class then
        self:GetOwner().Mesh:LinkAnimClassLayers(class)
    end
end

return AnimComp