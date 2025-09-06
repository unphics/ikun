
---
---@brief   投射物
---@author  zys
---@data    Sat Sep 06 2025 12:30:40 GMT+0800 (中国标准时间)
---

---@class BP_ProjectileBase: BP_ProjectileBase_C
local BP_ProjectileBase = UnLua.Class()

---@override
function BP_ProjectileBase:ReceiveBeginPlay()
    self.CollisionPawn.OnComponentBeginOverlap:Add(self, self.OnCollisionPawnBeginOverlap)
    self.CollisionEnv.OnComponentBeginOverlap:Add(self, self.OnCollisionEnvBeginOverlap)
end

---@override
function BP_ProjectileBase:ReceiveEndPlay()
    self.CollisionPawn.OnComponentBeginOverlap:Clear()
    self.CollisionEnv.OnComponentBeginOverlap:Clear()
end

---@override
function BP_ProjectileBase:ReceiveTick(DeltaSeconds)
    -- self:DrawArrowPath(DeltaSeconds)
end

---@private [Draw] 绘制箭矢的路径
function BP_ProjectileBase:DrawArrowPath(DeltaTime)
    if net_util.is_server(self) then
        return
    end
    local interval = 0.05
    if not self.curtime then
        self.curtime = DeltaTime
    else
        self.curtime = self.curtime + DeltaTime
    end
    if self.curtime > interval then
        self.curtime = self.curtime - interval
        UE.UKismetSystemLibrary.DrawDebugSphere(self, self:K2_GetActorLocation(), 40, 6, UE.FLinearColor(0, 0, 1), 10, 3)
    end
end

---@private
function BP_ProjectileBase:OnCollisionEnvBeginOverlap(OverlappedComponent, OtherActor, OtherComp, OtherBodyIndex, bFromSweep, SweepResult)
log.dev('BP_ProjectileBase:OnCollisionEnvBeginOverlap()', 'World')
    -- draw_util.draw_sphere(self:K2_GetActorLocation(), 50)
    self:StopAndStatic()
end

---@private
function BP_ProjectileBase:OnCollisionPawnBeginOverlap(OverlappedComponent, OtherActor, OtherComp, OtherBodyIndex, bFromSweep, SweepResult)
    log.dev('BP_ProjectileBase:OnCollisionPawnBeginOverlap()', '角色')
    self:StopAndStatic()
end

---@private 停止和静态化
function BP_ProjectileBase:StopAndStatic()
    self.ProjectileMovement:StopMovementImmediately()
    self.ProjectileMovement.ProjectileGravityScale = 0
    self.CollisionPawn:SetGenerateOverlapEvents(false)
    self.CollisionPawn.OnComponentBeginOverlap:Clear()
    self.CollisionEnv.OnComponentBeginOverlap:Clear()
end

return BP_ProjectileBase