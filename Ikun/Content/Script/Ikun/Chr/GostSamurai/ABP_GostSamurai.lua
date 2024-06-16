--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--

local IkunAnimInst = 'Ikun/Anim/Blueprint/IkunAnimInst'

---@type ABP_GostSamurai_C
local M = UnLua.Class(IkunAnimInst)

-- function M:Initialize(Initializer)
-- end

-- function M:BlueprintInitializeAnimation()
-- end

function M:BlueprintBeginPlay()
    self.Super.BlueprintBeginPlay(self)
    self.Overridden.BlueprintBeginPlay(self)
end

function M:BlueprintUpdateAnimation(DeltaTimeX)
    self.Super.BlueprintUpdateAnimation(self, DeltaTimeX)
    self.Overridden.BlueprintUpdateAnimation(self, DeltaTimeX)
end

-- function M:BlueprintPostEvaluateAnimation()
-- end

return M
