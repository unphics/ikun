--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--

---@type BP_Lich_C
local M = UnLua.Class()

---@private 私有方法的前向声明
local fn1 = function()end

---@public 公有方法的前向声明
M.fn2 = function()end

-- function M:Initialize(Initializer)
-- end

-- function M:UserConstructionScript()
-- end

function M:ReceiveBeginPlay()
    self.Overridden.ReceiveBeginPlay(self)
    local GA_Born_Class = UE.UClass.Load('/Game/Ikun/Chr/Lich/Skill/GA/Born/GA_Born.GA_Born_C')
    self.GABornHandle = self.ASC:K2_GiveAbility(GA_Born_Class, 1, 1)

    local GA_Spell_Class = UE.UClass.Load('/Game/Ikun/Chr/Lich/Skill/GA/Spell/GA_Spell.GA_Spell_C')
    self.GASpellHandle = self.ASC:K2_GiveAbility(GA_Spell_Class, 1, 1)

    local GA_Attack_Left_Class = UE.UClass.Load('/Game/Ikun/Chr/Lich/Skill/GA/Attack/GA_Attack_Left.GA_Attack_Left_C')
    self.GAAttackLeftHandle = self.ASC:K2_GiveAbility(GA_Attack_Left_Class, 1, 1)

    local GA_Attack_Right_Class = UE.UClass.Load('/Game/Ikun/Chr/Lich/Skill/GA/Attack/GA_Attack_Right.GA_Attack_Right_C')
    self.GAAttackRightHandle = self.ASC:K2_GiveAbility(GA_Attack_Right_Class, 1, 1)

end

-- function M:ReceiveEndPlay()
-- end

function M:ReceiveTick(DeltaSeconds)
    self.Overridden.ReceiveTick(self, DeltaSeconds)
end

-- function M:ReceiveAnyDamage(Damage, DamageType, InstigatedBy, DamageCauser)
-- end

-- function M:ReceiveActorBeginOverlap(OtherActor)
-- end

-- function M:ReceiveActorEndOverlap(OtherActor)
-- end

---@brief 私有方法的函数实现
fn1 = function()
    log.log("forward declare 2")
end
---@brief 公有方法的函数实现
function M:fn2()
    log.log("forward declare 4")
end

return M
