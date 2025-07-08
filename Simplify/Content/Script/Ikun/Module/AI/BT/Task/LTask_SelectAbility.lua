
---
---@brief   SelectAbility
---@author  zys
---@data    Thu Jan 09 2025 12:26:53 GMT+0800 (中国标准时间)
---

local BBKeyDef = require("Ikun.Module.AI.BT.BBKeyDef")

---@class LTask_SelectAbility: LTask
---@field ConstRequireTags string[] 必须tag
---@field SelectResult table
local LTask_SelectAbility = class.class 'LTask_SelectAbility' : extends 'LTask' {
--[[public]]
    ctor = function()end,
--[[private]]
    SelectAbilityRandom = function()end,
    SelectResult = nil,
    ConstRequireTags = nil,
}

---@override
function LTask_SelectAbility:ctor(NodeDispName, RequireTags)
    class.LTask.ctor(self, NodeDispName)
    self.SelectResult = nil
    self.ConstRequireTags = RequireTags or {}
end

---@override
function LTask_SelectAbility:OnInit()
    class.LTask.OnInit(self)
    self.SelectResult = nil

    self:SelectAbilityRandom()
end

---@override
function LTask_SelectAbility:OnUpdate(DeltaTime)
    if self.SelectResult then
        self.Blackboard:SetBBValue(BBKeyDef.SelectAbility, self.SelectResult)
        self.Blackboard:SetBBValue(BBKeyDef.MoveTarget, self.Blackboard:GetBBValue(BBKeyDef.FightTarget))
        self:DoTerminate(true)
    else
        self:DoTerminate(false)
    end
end

---@private 在一定条件下随机选择技能
function LTask_SelectAbility:SelectAbilityRandom()
    local OwnerRole = rolelib.role(self.Chr)
    local FightTargetRole = self.Blackboard:GetBBValue(BBKeyDef.FightTarget) ---@type RoleClass
    local FightTargetAvatar = FightTargetRole.Avatar ---@type BP_ChrBase

    if not obj_util.is_valid(FightTargetAvatar) or not rolelib.is_live_role(FightTargetRole) then
        ---@todo
        if not class.instanceof(OwnerRole.Team.CurTB, class.TB_Patrol) then
            return
        end
        FightTargetRole = OwnerRole.Team.CurTB:ReadDynaSuppressTarget(FightTargetRole:GetRoleInstId())
        FightTargetAvatar = FightTargetRole and FightTargetRole.Avatar
        if not obj_util.is_valid(FightTargetAvatar) or not rolelib.is_live_role(FightTargetRole) then
            return log.error('LTask_SelectAbility:SelectAbilityRandom(): 没有有效的敌人 !!!')
        end
    end

    local AllActiveAbility, AllHandle = gas_util.get_all_active_abilities(self.Chr)
    if not AllActiveAbility or #AllActiveAbility == 0 then
        return log.error('LTask_SelectAbility:SelectAbilityRandom(): 没有有效的主动技能 !!!')
    end
    
    local Dist = UE.UKismetMathLibrary.Vector_Distance(FightTargetAvatar:K2_GetActorLocation(), self.Chr:K2_GetActorLocation())
    local Forward = self.Chr:GetActorForwardVector()
    local SelfToTargetVec = FightTargetAvatar:GetActorForwardVector() - self.Chr:K2_GetActorLocation()

    ---@todo 过滤规则和权重计算有待补全

    -- 过滤
    local AbleSkill = {}
    for i, Ability in ipairs(AllActiveAbility) do
        -- if not math_util.is_zero(Ability.DirExtendYaw) then -- 方向过滤 和 方向权重
        -- end
        -- 距离过滤 和 距离权重
        -- 友方团队相关 团队过滤 及其 权重计算(团队组成/人数/健康度/斩首率/阵位)
        -- 敌方团队相关 团队过滤 及其 权重计算

        if #self.ConstRequireTags > 0 then
            for _, strTag in ipairs(self.ConstRequireTags) do
                if not UE.UBlueprintGameplayTagLibrary.HasTag(Ability.AbilityTags, UE.UIkunFnLib.RequestGameplayTag(strTag), false) then
                    goto all_continue
                end
            end
        end
        table.insert(AbleSkill, {Handle = AllHandle[i], Ability = AllActiveAbility[i]})
        ::all_continue::
    end

    -- 权重
    local widgetResultAbility = nil
    local totalWidget = 0
    for i, info in ipairs(AbleSkill) do
        totalWidget = totalWidget + info.Ability.SkillWeight
    end
    local rnd = math.random() * totalWidget
    local sum = 0
    for _, info in ipairs(AbleSkill) do
        sum = sum + info.Ability.SkillWeight
        if rnd <= sum then
            widgetResultAbility = info
            break
        end
    end

    self.SelectResult = widgetResultAbility ---@todo 这个选择结果考虑暴露更多信息
end

return LTask_SelectAbility