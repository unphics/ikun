
local NavPathData = require('System/Move/NavPathData')

local MoveState = {
    IDLE = 0,
    PENDING = 1, -- 等待 C++ 寻路回调
    MOVING = 2,  -- 正常行驶
    STUCK = 3,   -- 卡死处理中
}

local NavMoveBehav = class.class 'NavMoveBehav' {}

function NavMoveBehav:ctor(InChr, InConfig)
    self.Chr = InChr
    self.CurPathData = nil
    self.State = MoveState.IDLE
end

function NavMoveBehav:MoveTo(Target, OnComplate)
    if self.CurPathData then
        self.CurPathData:CancelFind()
        self.CurPathData = nil
    end
    local start = self.Chr:K2_GetActorLocation()
    local newPathData = NavPathData()
    self.State = MoveState.PENDING
    newPathData:FindNavPath(self.Chr, start, self:_GetTargetLoc(), nil, function(dt, b)
        if self.CurPathData ~= newPathData then
            return
        end
        if not b then
            self:Stop(false)
            if OnComplate then
                OnComplate(false)
            end
            return
        end
        self.State = MoveState.MOVING
    end)
end

function NavMoveBehav:Tick(DeltaTime)
    if self.State ~= MoveState.MOVING or not self.CurPathData then
        return
    end
    
end

function NavMoveBehav:Stop(bFinished)
    if self.State == MoveState.IDLE then
        return
    end
    if self.CurPathData then
        self.CurPathData:CancelMove()
        self.CurPathData = nil
    end
    self.State = MoveState.IDLE
end

function NavMoveBehav:_GetTargetLoc()
    local target = self.CurReq.Target
end

function NavMoveBehav:Destroy()
    if self.CurPathData then
        self.CurPathData:CancelMove()
        self.CurPathData = nil
    end
end