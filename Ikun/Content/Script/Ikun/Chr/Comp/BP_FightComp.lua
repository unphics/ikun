
---@class BP_FightComp
local BP_FightComp = UnLua.Class()

-- function BP_FightComp:Initialize(Initializer)
--     self.Overridden.Initialize(self)
-- end

function BP_FightComp:ReceiveBeginPlay()
end

-- function BP_FightComp:ReceiveEndPlay()
-- end

function BP_FightComp:ReceiveTick(DeltaSeconds)
end

---@public [InFight] 主动警戒/入战
function BP_FightComp:Equip()
end

return BP_FightComp