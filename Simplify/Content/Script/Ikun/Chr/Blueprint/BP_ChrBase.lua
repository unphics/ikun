---
---@brief
---@author zys
---@data Sun Mar 02 2025 02:19:44 GMT+0800 (中国标准时间)
---

---@class BP_ChrBase: BP_ChrBase_C
---@field Role RoleClass
local BP_ChrBase = UnLua.Class()

-- function BP_ChrBase:Initialize(Initializer)
-- end

-- function BP_ChrBase:UserConstructionScript()
-- end

---@protected [ImplBP]
function BP_ChrBase:ReceiveBeginPlay()
    self.Overridden.ReceiveBeginPlay(self)
    self.MsgBusComp:PrepareInitChrDataEvent()
    self.MsgBusComp:PrepareInitChrDisplayEvent()
    self.MsgBusComp:RegEvent('ChrInitData', self, self.OnChrInitData)
end

-- function BP_ChrBase:ReceiveEndPlay()
-- end

---@protected [ImplBP]
function BP_ChrBase:ReceiveTick(DeltaSeconds)
    self.Overridden.ReceiveTick(self, DeltaSeconds)
    if not self.Dead and net_util.is_server(self) then
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

---@public [Server]
---@return RoleClass | nil
function BP_ChrBase:GetRole()
    if not obj_util.is_valid(self) then
        return log.error('BP_ChrBase:GetRole() Has Released')
    end
    return self.RoleComp.Role
end

---@public [Server]
---@return string
function BP_ChrBase:PrintRoleInfo()
    local Role = self:GetRole()
    return ' [Actor='..obj_util.dispname(self)..', RoleName='..Role.DisplayName..', RoleId='..Role.RoleInstId..'] '
end

---@private
function BP_ChrBase:OnChrInitData()
    if net_util.is_client(self) then
        return
    end
    local ActiveAbilities = self.ActiveAbilities:ToTable()
    for _, AbilityClass in ipairs(ActiveAbilities) do
        local Handle = self.ASC:K2_GiveAbility(AbilityClass, 0, 0)
        if Handle.Handle == -1 then
            log.error('Failed to Give Ability')
        end
    end
end

---@private Chr开始死亡
function BP_ChrBase:ChrBeginDeath()
    self.Dead = true
    if self:GetRole() then
        self:GetRole():RoleBeginDeath()
        async_util.delay(self, 0.1, function()
            self:K2_DestroyActor()
        end)
    end
end
return BP_ChrBase
