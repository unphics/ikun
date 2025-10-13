
---
---@brief   Ikun中用到的所有行为树的定义
---@author  zys
---@data    Sun Jan 19 2025 20:20:36 GMT+0800 (中国标准时间)
---@desc    包含很多通用行为树和角色专用行为树
---

local BBKeyDef = require('Ikun/Module/AI/BT/BBKeyDef')
local BehavDef = require("Ikun.Module.AI.BT.Behav.BehavDef")

local M = {}

---@brief 团队组队行为树1
---@return LBT
M['Team_MakeTeam_1'] = function(Avatar)
    local LBT = class.new 'LBT' (nil, Avatar, 'Team_MakeTeam_1') ---@as LBT
    LBT:CreateRoot()
        :AddSequence()
            :AddTask("LTask_Wait", 2)
            :AddTask('LTask_MakeTeam')
            :AddTask('LTask_Wait', 1)
            :AddTask('LTask_TeamWaitSwitchBT')
    return LBT
end

---@brief 团队协同巡逻行为树1
M['Team_Patrol_Together_1'] = function(Avatar)
    local LBT = class.new 'LBT'(nil, Avatar, 'Team_Patrol_Together_1') ---@as LBT
    LBT:CreateRoot()
        :AddSelector()
            :AddService('LService_TeamAlert', 0.3, 1500)
            :AddService('LService_NeedSwitchBT', 0.3)
            :AddSequence()
                :AddTask('LTask_Wait', 1)
                :AddTask('LTask_TeamGetMoveTarget')
                :AddTask('LTask_RotateSmooth')
                :AddTask('LTask_Wait', 0.2)
                :AddTask('LTask_TeamMove', 200, 160, 3, UE.FVector(200, 200, 200))
                :AddTask('LTask_TeamWaitFence')
    return LBT
end

---@brief 团队战斗行为树1
M['Team_Fight_1'] = function(Avatar)
    local LBT = class.new 'LBT'(nil, Avatar, 'Team_Fight_1') ---@as LBT
    LBT:CreateRoot()
        :AddSelector()
            -- 团队控制强制指挥(紧急掩护, 紧急位移等)
            -- 战斗单位自主行为
            :AddSequence()
                :AddTask('LTask_Wait', 1, 0.5)
                :AddTask('LTask_ClearBBValue', BBKeyDef.MoveTarget, BBKeyDef.FightTarget)
                :AddTask('LTask_GetTBInfo2BB', 'DirectiveMoveCoord', BBKeyDef.MoveTarget)
                :AddDecorator('LDecorator_BBCondition', BBKeyDef.MoveTarget)
                :AddSequence()
                    :AddTask('LTask_RotateSmooth')
                    :AddTask('LTask_Wait', 0.2)
                    :AddTask('LTask_AiMoveBase', 200, 160, 3, UE.FVector(200, 200, 200))
                :Up()
                :AddTask('LTask_GetTBInfo2BB', 'DynaSuppressTarget', BBKeyDef.FightTarget)
                :AddDecorator('LDecorator_BBCondition', BBKeyDef.FightTarget)
                :AddSequence()
                    :AddTask('LTask_Wait', 0.5, 0.5)
                    :AddTask('LTask_SelectAbility')
                    -- :AddDecorator('LDecorator_NeedRepos4Ability')
                    -- :AddSequence()
                    --     :AddTask('LTask_FindLoc4Ability')
                    --     :AddTask('LTask_RotateSmooth')
                    --     :AddTask('LTask_Wait', 0.2)
                    --     :AddTask('LTask_Move4Repos', 20, 160, 3, UE.FVector(200, 200, 200))
                    -- :Up()
                    -- :AddService('LService_ReposJudge', 0.3)
                    :AddDecorator('LDecorator_NeedRepos4Ability')
                    :AddSequence()
                        :AddTask('LTask_ClearBBValue', BBKeyDef.MoveTarget)
                        :AddTask('LTask_FindLoc4Ability')
                        :AddTask('LTask_RotateSmooth')
                        :AddTask('LTask_Wait', 0.2)
                        :AddTask('LTask_Move4Repos', 20, 160, 3, UE.FVector(200, 200, 200))
                    :Up()
                    :AddTask('LTask_AimTarget')
                    :AddTask('LTask_ActiveAbility')
    return LBT
end

---@brief 团队战斗行为树2
M['Team_Fight_2'] = function(Avatar)
    local LBT = class.new 'LBT'(nil, Avatar, 'Team_Fight_2') ---@as LBT
    LBT:CreateRoot()
        :AddSelector()
            :AddSequence()
                :AddService('LService_NeedSwitchBT', 0.3)
                :AddService('LService_ConsiderBehav', 0.3)
                :AddService('LService_MoveBehav', 0)
                :AddSequence()
                    :AddTask('LTask_NextBehav')
                    :AddSelector()
                        :AddDecorator('LDecorator_IsBehav', BehavDef.Special)
                        :AddSequence()
                            :AddTask('LTask_ClearBBValue', BBKeyDef.MoveTarget)
                            :AddTask('LTask_GetTBInfo2BB', 'DirectiveMoveCoord', BBKeyDef.MoveTarget)
                            :AddTask('LTask_RotateSmooth')
                            :AddTask('LTask_WaitMoveArrived', BBKeyDef.MoveTarget)
                        :Up()
                        :AddDecorator('LDecorator_IsBehav', BehavDef.Survive)
                        :AddSequence()
                            :AddTask('LTask_NeedSupportSurvive')
                            -- 如果当前地点安全就零散放几个技能; 否则就去安全区
                            :AddTask("LTask_FindSafeArea")
                            :AddTask('LTask_WaitMoveArrived', BBKeyDef.SafeLoc)
                        :Up()
                        :AddDecorator('LDecorator_IsBehav', BehavDef.Support)
                        :AddSequence()
                            -- 找个需要支援的, 释放支援技能(先原地释放, 略过走位等)
                            :AddTask("LTask_FindSupportTarget")
                            :AddTask("LTask_SelectAbility", {'Skill.Tag.Support'})
                            :AddTask('LTask_ActiveAbility')
                        :Up()
                        :AddDecorator('LDecorator_IsBehav', BehavDef.Attack)
                        :AddSequence()
                            :AddTask('LTask_GetTBInfo2BB', 'DynaSuppressTarget', BBKeyDef.FightTarget)
                            :AddDecorator('LDecorator_BBCondition', BBKeyDef.FightTarget)
                            :AddSequence()
                                :AddTask('LTask_SelectAbility', {'Skill.Tag.Attack'})
                                :AddSelector()
                                    :AddDecorator('LDecorator_NeedRepos4Ability')
                                    :AddSequence()
                                        :AddTask('LTask_ClearBBValue', BBKeyDef.MoveTarget)
                                        :AddTask('LTask_FindLoc4Ability')
                                        :AddTask('LTask_RotateSmooth')
                                        :AddTask('LTask_Wait', 0.2)
                                        :AddTask('LTask_Move4Repos', 20, 160, 3, UE.FVector(200, 200, 200))
                                    :Up()
                                    :AddTask('LTask_RandomResult', 1)
                                :Up()
                                :AddTask('LTask_AimTarget')
                                :AddTask('LTask_ActiveAbility')
                            :Up()
                        :Up()
    return LBT
end

---@brief 通用出生行为树1
---@version 0.1.0 只用来给野怪出生用, 出生时处理一些除动画以外的其他事情, 如选择头领等
---@return LBT
M['JungleMonsters_Burn_1'] = function(Avatar)
    local LBT = class.new 'LBT' (nil, Avatar, 'JungleMonsters_Burn_1') ---@as LBT
    LBT:CreateRoot()
        :AddSequence()
            :AddTask("LTask_Wait", 3)
            :AddTask('LTask_MakeTeam')
            :AddTask('LTask_SwitchBT', 'JungleMonsters_Peace_1')
    return LBT
end

---@brief 野怪通用和平行为树1
---@version 0.1.0 初版只有一些简单的行为; 随机移动, 周围有其他Enemy就进入战斗 --2025/1/19
---@return LBT
M['JungleMonsters_Peace_1'] = function(Avatar)
    local LBT = class.new 'LBT' (nil, Avatar, 'JungleMonsters_Peace_1') ---@as LBT
    LBT:CreateRoot()
        :AddSelector()
            :AddDecorator('LDecorator_RoleCondition', 'HasTarget')
            -- :AddTask('LTask_Wait', 1)
            :AddTask('LTask_SwitchBT', 'JungleMonsters_Fight_1')
            :AddService('LService_Alert', 0.3, 1500)
            :AddSequence()
                :AddTask('LTask_Wait', 1.5, 1)
                :AddTask('LTask_RandNavTarget', 500, 2000)
                :AddTask('LTask_RotateSmooth')
                :AddTask('LTask_Wait', 0.1) ---@note 转身后停0.1秒再走的表现效果不错
                :AddTask('LTask_AiMoveBase', 200, 160, 3, UE.FVector(200, 200, 200))
    return LBT
end

---@brief 野怪通用战斗行为树1
---@version 0.0.1 初版只能选择技能再激活技能 --2025/1/19
---@return LBT
M['JungleMonsters_Fight_1'] = function(Avatar)
    local LBT = class.new 'LBT' (nil, Avatar, 'JungleMonsters_Fight_1') ---@as LBT
    LBT:CreateRoot()
        :AddSelector()
            :AddDecorator('LDecorator_RoleCondition', 'HasTarget')
            :AddSequence()
                :AddTask('LTask_Wait', 1, 0.3)
                :AddTask('LTask_SelectAbility')
                :AddTask('LTask_RotateSmooth')
                :AddTask('LTask_AiMoveBase', 2000, 160, 3, UE.FVector(200, 200, 200))
                -- :AddDecorator()
                :AddTask('LTask_RotateSmooth', nil, 1)
                :AddTask('LTask_ActiveAbility')
            :Up()
            :AddSequence()
                :AddTask('LTask_Wait', 1)
                :AddTask('LTask_SwitchBT', 'JungleMonsters_Peace_1')
    return LBT
end

---@brief 城市/村镇的和平Npc
M['Dweller_Peace'] = function(Avatar)
    local lbt = class.new'LBT'(nil, Avatar, 'Dweller_Peace') ---@as LBT
    lbt:CreateRoot()
    return lbt
end

---@brief 站立不动
M['Stand'] = function(Avatar)
    local LBT = class.new 'LBT' (nil, Avatar, 'Stand') ---@as LBT
    LBT:CreateRoot()
        :AddSelector()
            :AddTask('LTask_Wait', 10)
    return LBT
end

return M

--[[

local function NewBT(Name, CreateFn)
    M[Name] = function(Avatar)
        local LBT = class.new 'LBT' (nil, Avatar, Name) ---@type LBT
        CreateFn(LBT)
        return LBT
    end
end
-- 团队组队行为树1
NewBT('Team_MakeTeam_1', function(BT)
    BT:CreateRoot()
        :AddSequence()
            :AddTask('LTask_SwitchBT')
            :AddTask("LTask_Wait", 3)
            :AddTask('LTask_MakeTeam')
            :AddTask('LTask_SwitchBT', 'Team_Patrol_Together_1')
end)

]]