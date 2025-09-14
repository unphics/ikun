---
---@brief   角色(chr)的基类
---@author  zys
---@data    Sun Mar 02 2025 02:19:44 GMT+0800 (中国标准时间)
---

---@class BP_ChrBase: BP_ChrBase_C
---@field Role RoleClass
local BP_ChrBase = UnLua.Class()

-- function BP_ChrBase:Initialize(Initializer)
-- end

-- function BP_ChrBase:UserConstructionScript()
-- end

---@override [ImplBP]
function BP_ChrBase:ReceiveBeginPlay()
    self.Overridden.ReceiveBeginPlay(self)
    self.MsgBusComp:PrepareInitChrDataEvent()
    self.MsgBusComp:PrepareInitChrDisplayEvent()
    self.MsgBusComp:RegEvent('ChrInitData', self, self.OnChrInitData)
end

-- function BP_ChrBase:ReceiveEndPlay()
-- end

---@override [ImplBP]
function BP_ChrBase:ReceiveTick(DeltaSeconds)
    self.Overridden.ReceiveTick(self, DeltaSeconds)
    if not self.bChrDead and net_util.is_server(self) then
        local HP = self.AttrSet:GetAttrValueByName("Health")
        if math_util.is_zero(HP) then
            self:ChrBeginDeath()
        end
    end
end

-- function BP_ChrBase:ReceiveAnyDamage(Damage, DamageType, InstigatedBy, DamageCauser)
-- end

-- function BP_ChrBase:ReceiveActorBeginOverlap(OtherActor)
-- end

-- function BP_ChrBase:ReceiveActorEndOverlap(OtherActor)
-- end

---@public [Server] [Tool] [Pure] 获取当前Chr的Role
---@return RoleClass | nil
function BP_ChrBase:GetRole()
    if not obj_util.is_valid(self) then
        return log.error('BP_ChrBase:GetRole() Has Released')
    end
    return self.RoleComp.Role
end

---@public [Server] [Tool] [Pure] [Debug] 打印当前角色的一些信息
---@return string
function BP_ChrBase:PrintRoleInfo()
    local Role = self:GetRole()
    return ' [Actor='..obj_util.dispname(self)..', RoleName='..Role:GetRoleDispName()..', RoleId='..Role:GetRoleInstId()..'] '
end

---@private 角色在数据初始化的时候给自己赋予所有的技能
function BP_ChrBase:OnChrInitData()
    if net_util.is_client(self) then
        return
    end
    local ActiveAbilities = self.ActiveAbilities:ToTable()
    for _, AbilityClass in ipairs(ActiveAbilities) do
        local Handle = self.ASC:K2_GiveAbility(AbilityClass, 0, 0)
        if not Handle or Handle.Handle == -1 then
            log.error('BP_ChrBase:OnChrInitData()', 'Failed to Give Ability')
        end
    end
end

---@private Chr开始死亡
function BP_ChrBase:ChrBeginDeath()
    self.bChrDead = true
    if self:GetRole() then
        self:GetRole():RoleBeginDeath()
        async_util.delay(self, 0.1, function()
            self:K2_DestroyActor()
        end)
    end
end

---@public [Input]
function BP_ChrBase:MoveForwardBack(Fwd, Value)
    local rot = self:GetControlRotation()
    local yawRot = UE.FRotator(0, rot.Yaw, 0)
    local fornt = yawRot:GetForwardVector()
    self:AddMovementInput(fornt, Value, false)    
end

---@public [Input]
function BP_ChrBase:MoveRightLeft(Fwd, Value)
    local rot = self:GetControlRotation()
    local yawRot = UE.FRotator(0, rot.Yaw, 0)
    local right = yawRot:GetRightVector()
    self:AddMovementInput(right, Value, false)
end

function BP_ChrBase:C2S_Jump()
    self:Jump()
end

return BP_ChrBase