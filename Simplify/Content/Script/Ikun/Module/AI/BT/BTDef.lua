---
---@brief Ikun中用到的所有行为树的定义
---@author zys
---@data Sun Jan 19 2025 20:20:36 GMT+0800 (中国标准时间)
---@desc 包含很多通用行为树和角色专用行为树
---

local M = {}

---@brief 团队组队行为树1
---@version 0.1.0 组队
---@return LBT
M['Team_MakeTeam_1'] = function(Avatar)
    local LBT = class.new 'LBT' (nil, Avatar, 'Team_MakeTeam_1') ---@type LBT
    LBT:CreateRoot()
        :AddSequence()
            :AddTask("LTask_Wait", 2)
            :AddTask('LTask_MakeTeam')
            :AddTask('LTask_Wait', 1)
            :AddTask('LTask_TeamWaitSwitchBT')
    return LBT
end

---@brief 团队一起巡逻行为树1
---@version 0.1.0 一起随机找点巡逻
M['Team_Patrol_Together_1'] = function(Avatar)
    local LBT = class.new 'LBT'(nil, Avatar, 'Team_Patrol_Together_1') ---@type LBT
    LBT:CreateRoot()
        :AddSelector()
            :AddDecorator('LDecorator_TeamCondition', 'IsInfight')
            :AddTask('LTask_SwitchBT', '') ---@todo 瞬间让团队所有人跳去战斗
            :AddService('LService_Alert', 0.3, 1500)
            :AddSequence()
                :AddTask('LTask_Wait', 1, 0.5)
                :AddTask('LTask_TeamNavTarget')
                --[[
                    选一个地方
                    转身
                    wait0.1
                    所有人一起去
                    等待所有人都到了
                ]]
    return LBT
end

---@brief 通用出生行为树1
---@version 0.1.0 只用来给野怪出生用, 出生时处理一些除动画以外的其他事情, 如选择头领等
---@return LBT
M['JungleMonsters_Burn_1'] = function(Avatar)
    local LBT = class.new 'LBT' (nil, Avatar, 'JungleMonsters_Burn_1') ---@type LBT
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
    local LBT = class.new 'LBT' (nil, Avatar, 'JungleMonsters_Peace_1') ---@type LBT
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
    local LBT = class.new 'LBT' (nil, Avatar, 'JungleMonsters_Fight_1') ---@type LBT
    LBT:CreateRoot()
        :AddSelector()
            :AddDecorator('LDecorator_RoleCondition', 'HasTarget')
            :AddSequence()
                :AddTask('LTask_Wait', 1, 0.3)
                :AddTask('LTask_SelectAbility')
                :AddTask('LTask_RotateSmooth')
                :AddTask('LTask_AiMoveBase', 2000, 160, 3, UE.FVector(200, 200, 200))
                ---@todo 转向/靠近/调整站位
                -- :AddDecorator()
                :AddTask('LTask_RotateSmooth', nil, 1)
                :AddTask('LTask_ActiveAbility')
            :Up()
            :AddSequence()
                ---@todo 先索敌
                :AddTask('LTask_Wait', 1)
                :AddTask('LTask_SwitchBT', 'JungleMonsters_Peace_1')
            ---@todo 脱战
    return LBT
end

---@brief 城市/村镇的和平Npc

---@brief 站立不动
M['Stand'] = function(Avatar)
    local LBT = class.new 'LBT' (nil, Avatar, 'Stand') ---@type LBT
    LBT:CreateRoot()
        :AddSelector()
            :AddTask('LTask_Wait', 10)
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