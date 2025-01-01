--
-- DESCRIPTION
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--

---@class BP_Lich: BP_Lich_C
local M = UnLua.Class('/Ikun/Chr/Blueprint/BP_ChrBase')

-- function M:Initialize(Initializer)
-- end

-- function M:UserConstructionScript()
-- end

function M:ReceiveBeginPlay()
    -- self.Overridden.ReceiveBeginPlay(self)
    self.Super.ReceiveBeginPlay(self)
    local GA_Born_Class = UE.UClass.Load('/Game/Ikun/Chr/Lich/Skill/GA/Born/GA_Born.GA_Born_C')
    self.GABornHandle = self.ASC:K2_GiveAbility(GA_Born_Class, 1, 1)

    local GA_Spell_Class = UE.UClass.Load('/Game/Ikun/Chr/Lich/Skill/GA/Spell/GA_Spell.GA_Spell_C')
    self.GASpellHandle = self.ASC:K2_GiveAbility(GA_Spell_Class, 1, 1)

    local GA_Attack_Left_Class = UE.UClass.Load('/Game/Ikun/Chr/Lich/Skill/GA/Attack/GA_Attack_Left.GA_Attack_Left_C')
    self.GAAttackLeftHandle = self.ASC:K2_GiveAbility(GA_Attack_Left_Class, 1, 1)

    local GA_Attack_Right_Class = UE.UClass.Load('/Game/Ikun/Chr/Lich/Skill/GA/Attack/GA_Attack_Right.GA_Attack_Right_C')
    self.GAAttackRightHandle = self.ASC:K2_GiveAbility(GA_Attack_Right_Class, 1, 1)

    self.MsgBusComp:RegEvent("ChrInitDisplay", self, self.InitLichColor)
end

-- function M:ReceiveEndPlay()
-- end

function M:ReceiveTick(DeltaSeconds)
    self.Overridden.ReceiveTick(self, DeltaSeconds)
    -- self:LBT_Test(DeltaSeconds)
end

-- function M:ReceiveAnyDamage(Damage, DamageType, InstigatedBy, DamageCauser)
-- end

-- function M:ReceiveActorBeginOverlap(OtherActor)
-- end

-- function M:ReceiveActorEndOverlap(OtherActor)
-- end

function M:InitLichColor()
    if net_util.is_client(self) then
        return
    end
    local RoleConfig = self.NpcComp.Role.RoleConfig ---@type RoleConfig
    if not RoleConfig then
        return
    end
    if RoleConfig.Color > 0 then
        local Color = UE.FLinearColor(1, 0, 0, 1)
        self:SetLichColor(Color)
    end
end

---@param Color FLinearColor
function M:SetLichColor_RPC(Color)
    local MeshSrcMat = self.Mesh:GetMaterials():Get(1) ---@type UMaterialInterface
    local DynMatInst = self.Mesh:CreateDynamicMaterialInstance(0, MeshSrcMat) ---@type UMaterialInstanceDynamic
    DynMatInst:SetVectorParameterValue('Emissive Color', Color)

    self.PointLight:SetLightColor(Color, true)

    local ParticleSrcMat = self.ParticleSystem:GetMaterial(0)
    local ParticleDynMatInst = self.ParticleSystem:CreateDynamicMaterialInstance(0, ParticleSrcMat)
    ParticleDynMatInst:SetVectorParameterValue('Smpke_COlor', Color)

    local FXSrcMat = self.Smoke_FX:GetMaterial(0)
    local FXDynMatInst = self.Smoke_FX:CreateDynamicMaterialInstance(0, FXSrcMat)
    FXDynMatInst:SetVectorParameterValue('Smpke_COlor', Color)
end


function M:LBT_Test(DeltaSeconds)
    if net_util.is_server(self) then
        return
    end
    if not self.LBT then
        local LBT = class.new 'LBT' (nil, self) ---@type LBT
        self.LBT = LBT
        LBT:CreateRoot()
            :AddSelector()
                :AddDecorator('有对手')
                :AddSequence()
                    :AddTask('选技能')
                    :AddSelector()
                        :AddDecorator('需要转身')
                        :AddTask('转身')
                        :AddTask('立刻成功')
                    :Up()
                    :AddSelector()
                        :AddDecorator('需要移动')
                        :AddTask('移动')
                        :AddTask('立刻成功')
                    :Up()
                    :AddTask('放技能')
                :Up()
                :AddSequence()
                    :AddTask('选地点')
                    :AddTask('转身')
                    :AddTask('巡逻走')

        -- LBT:CreateRoot()
        --     :AddSelector()
        --         :AddTask('失败')
        --         :AddTask('发呆')
        
        -- LBT:CreateRoot()
        --         :AddSequence()
        --             :AddTask('发呆')
        --             :AddTask('发呆')

        -- LBT:CreateRoot()
        --         :AddSelector()
        --             :AddSelector()
        --                 :AddTask('失败')
        --                 :AddTask('失败')
        --             :Up()
        --             :AddSequence()
        --                 :AddTask('发呆')
        --                 :AddTask('发呆')

        -- LBT:CreateRoot()
        --     :AddSelector()
        --         :AddDecorator('成功')
        --         :AddTask('失败')
        --         :AddTask('发呆')
        self.count = 0
        log.error('LBT init', UE.UKismetSystemLibrary.IsServer(self))
    else
        self.count = self.count + DeltaSeconds
        local th = 1
        if self.count > th then
            self.LBT:Tick(self.count)
            self.count = 0
            local Text = self.LBT:PrintBT()
            local MainHud = ui_util.uimgr:GetUIInst(ui_util.uidef.UIInfo.MainHud)
            MainHud.TxtLog:SetText(Text)
        end

        -- self.LBT:Tick(DeltaSeconds)
        -- local Text = self.LBT:PrintBT()
        -- local MainHud = ui_util.uimgr:GetUIInst(ui_util.uidef.UIInfo.MainHud)
        -- MainHud.TxtLog:SetText(Text)
    end
end

return M
