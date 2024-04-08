--
-- DESCRIPTION 决策
--
-- @COMPANY **
-- @AUTHOR **
-- @DATE ${date} ${time}
--

local FarOrNearDistance = 800 -- 远程和近战分界距离

---@type BTTask_Decision_C
local M = UnLua.Class()

function M:ReceiveExecuteAI(OwnerController, ControlledPawn)
    self.Overridden.ReceiveExecuteAI(self, OwnerController, ControlledPawn)
    
    local BB = UE.UAIBlueprintHelperLibrary.GetBlackboard(OwnerController)
    local FightTargetActor = BB:GetValueAsObject('FightTargetActor')
    local CanAim = actor_util.is_no_obstacles_between(ControlledPawn, FightTargetActor)
    local Distance = ControlledPawn:GetDistanceTo(FightTargetActor)

    -- self:LotPotDecision(Distance)

    if Distance > FarOrNearDistance then
        log.warn('远程')
        -- TODO 随机远距离移动
        -- TODO 考虑障碍物遮挡(can aim)
        -- TODO 释放远程技能
        
        local ActivableAbilities = gas_util.find_abilities_by_name(ControlledPawn, 'Chr.Skill.Far')
        
        -- TODO Last
        
        -- local Distance = Ability.Distance
        -- BB:SetValueAsObject('FightTargetActor', NearbyActor)
    else
        -- TODO 增加血量因素
        log.warn('近战')
        -- TODO 追逐至攻击范围内
        -- TODO 释放近战技能
    end
    
    self:FinishExecute(true)
end

function M:LotPotDecision(Distance)
    local pot = decision_util.lot_pot:new()
    local far = pot:add_stick(true)
    local near = pot:add_stick(false)
    far:add_weight(Distance)
    near:add_weight((Distance > FarOrNearDistance) and (FarOrNearDistance / 2) or (FarOrNearDistance + Distance))
    if pot:draw_lot() then
        log.warn('放个远程技能', Distance)
    else
        log.warn('放个近战技能', Distance)
    end
end

return M

--[[
    在描述战斗中两个人的走位或者战争中部队向有利阵型的移动时，有几个常用的术语和短语可以使用：
    Maneuvering (Maneuver)：表示灵活地移动以获取优势位置或战术优势。例如："The soldiers maneuvered into position for a flanking attack."
    Advance/Advance Movement：表示向前移动，通常是指向敌人的方向。例如："The army advanced towards the enemy lines."
    Flanking：表示通过侧面或背后进攻目标，以制造围剿或混乱。例如："The cavalry flanked the enemy infantry, catching them off guard."
    Retreat/Retreat Movement：表示向后撤退或撤离战场。例如："The troops were ordered to retreat after suffering heavy casualties."
    Charge：表示突击或猛攻，通常是指迅速向敌方阵线移动以进行攻击。例如："The knights charged bravely into battle."
    Engagement：表示参与战斗或战斗中的交锋。例如："The infantry units engaged in fierce combat."
    Deployment：表示部署军队或者站定在特定位置。例如："The commander ordered the deployment of archers behind the infantry lines."
    Withdrawal：表示撤退或退出战斗，通常是有序的撤退。例如："The general ordered a strategic withdrawal to reassess the situation."
    Skirmish：表示小规模的战斗或者交火。例如："There were several skirmishes along the border between the two kingdoms."
    这些术语和短语可以帮助描述战斗中个人或军队的行动和位置变化。
]]