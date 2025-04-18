---
---@brief SelectAbility
---@author zys
---@data Thu Jan 09 2025 12:26:53 GMT+0800 (中国标准时间)
---

---@class LTask_SelectAbility: LTask
local LTask_SelectAbility = class.class 'LTask_SelectAbility' : extends 'LTask' {
--[[public]]
    ctor = function()end,
--[[private]]
    SelectAbilityRandom = function()end,
    SelectResult = nil,
}
function LTask_SelectAbility:ctor(DisplayName)
    class.LTask.ctor(self, DisplayName)
    self.SelectResult = nil
end
function LTask_SelectAbility:OnInit()
    class.LTask.OnInit(self)
    self.SelectResult = nil

    self:SelectAbilityRandom()
end
function LTask_SelectAbility:OnUpdate(DeltaTime)
    if self.SelectResult then
        self.Blackboard:SetBBValue('SelectAbility', self.SelectResult)
        self.Blackboard:SetBBValue('MoveTarget', self.Blackboard:GetBBValue('Target'))
        self:DoTerminate(true)
    else
        self:DoTerminate(false)
    end
end
function LTask_SelectAbility:SelectAbilityRandom()
    local CurEnemyTarget = self.Blackboard:GetBBValue('Target').Avatar ---@type AActor
    if not CurEnemyTarget then
        log.error('LTask_SelectAbility:SelectAbilityRandom() Failed to index valid enemy target !')
        return 
    end
    local AllActiveAbility, AllHandle = gas_util.get_all_active_abilities(self.Chr)
    local Dist = UE.UKismetMathLibrary.Vector_Distance(CurEnemyTarget:K2_GetActorLocation(), self.Chr:K2_GetActorLocation())
    local Forward = self.Chr:GetActorForwardVector()
    local SelfToTargetVec = CurEnemyTarget:GetActorForwardVector() - self.Chr:K2_GetActorLocation()
    ---@todo 过滤规则和权重计算有待补全
    for _, Ability in ipairs(AllActiveAbility) do
        -- if not math_util.is_zero(Ability.DirExtendYaw) then -- 方向过滤 和 方向权重

        -- end
        -- 距离过滤 和 距离权重
        -- 友方团队相关 团队过滤 及其 权重计算(团队组成/人数/健康度/斩首率/阵位)
        -- 敌方团队相关 团队过滤 及其 权重计算
    end
    local i = 1
    self.SelectResult = {Handle = AllHandle[i], Ability = AllActiveAbility[i]} ---@todo 这个选择结果考虑暴露更多信息
    -- log.dev('LTask_SelectAbility:SelectAbilityRandom()', self.SelectResult.Handle.Handle, self.SelectResult.Handle.Ability)
end