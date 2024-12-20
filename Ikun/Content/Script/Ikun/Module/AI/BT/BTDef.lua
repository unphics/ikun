local M = {}

---@return LBT
M[1] = function(Avatar)
    local LBT = class.new 'LBT' (nil, Avatar) ---@type LBT
    LBT:CreateRoot()
        :AddSelector()
            :AddDecorator('LDecorator_RoleCond', 'HasTarget')
            :AddTask('LTask_Wait', 5)
            :AddSequence()
                :AddTask('LTask_Wait', 2)
                :AddTask('LTask_AiMoveBase', 200, 160, 3, UE.FVector(200, 200, 200))
    return LBT
end

---@return LBT
M[2] = function(Avatar)
    local LBT = class.new 'LBT' (nil, Avatar) ---@type LBT
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
    return LBT
end

return M