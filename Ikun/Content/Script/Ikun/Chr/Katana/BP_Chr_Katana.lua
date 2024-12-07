--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--

local ERotMode = UE.UObject.Load('/Game/Ikun/Anim/Blueprint/Enum/RotMode.RotMode')
local EGait = UE.UObject.Load('/Game/Ikun/Anim/Blueprint/Enum/Gait.Gait')

---@class BP_Chr_Katana : BP_ChrBase
local BP_Chr_Katana = UnLua.Class('/Ikun/Chr/Blueprint/BP_ChrBase')

-- function BP_Chr_Katana:Initialize(Initializer)
-- end

-- function BP_Chr_Katana:UserConstructionScript()
-- end

function BP_Chr_Katana:ReceiveBeginPlay()
    self.Overridden.ReceiveBeginPlay(self)

    self.AnimComp.RotMode = ERotMode.LookDir
    self.AnimComp.Gait = EGait.Run

    if self:HasAuthority() then
        local ability_normal = UE.UClass.Load('/Game/Ikun/Chr/Katana/Skill/Skill_01_Attack_01/GA_Katana_Skill_01.GA_Katana_Skill_01_C')
        self.handle = self.ASC:K2_GiveAbility(ability_normal, 0, 0)
    end
end

-- function BP_Chr_Katana:ReceiveEndPlay()
-- end

function BP_Chr_Katana:ReceiveTick(DeltaSeconds)
end

-- function BP_Chr_Katana:ReceiveAnyDamage(Damage, DamageType, InstigatedBy, DamageCauser)
-- end

-- function BP_Chr_Katana:ReceiveActorBeginOverlap(OtherActor)
-- end

-- function BP_Chr_Katana:ReceiveActorEndOverlap(OtherActor)
-- end

---@public [Input] [Server] [Override] 普攻
---@param self BP_Chr_Katana
BP_Chr_Katana.NormalAttack = function(self)
    if not self.FightComp:CheckFight() then
        return
    end
    -- log.error('BP_Chr_Katana.NormalAttack 111', self:HasAuthority(), gas_util.find_active_by_name(self, 'Chr.Skill.01'))
    if gas_util.asc_has_tag_by_name(self, 'Chr.Skill.01') then
        local tag = UE.UIkunFuncLib.RequestGameplayTag("Input.MouseLeft.Down")
        local payload = UE.FGameplayEventData()
        payload.EventTag = tag
        payload.Instigator = self
        UE.UAbilitySystemBlueprintLibrary.SendGameplayEventToActor(self, tag, payload)
        return
    end

    self.FightComp:Equip() -- 主动入战
    self.ASC:TryActivateAbility(self.handle)
end

return BP_Chr_Katana