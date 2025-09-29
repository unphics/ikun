
---
---@brief   规划器
---@author  zys
---@data    Sat Sep 27 2025 20:43:08 GMT+0800 (中国标准时间)
---

---@class GPlanner
local GPlanner = class.class'GPlanner' {}

--[[
OpenList = {StartState}
ClosedList = {}
while Openlist不空:
    node = OpenList中取出f最小的
    if node == 目标:
        return 动作序列

    把node加入ClosedList
    for action in 所有Action:
        if action 可执行:
            newState = 应用效果(node.State)
            if newState不在ClosedList:
                加入OpenList
end
]]

---@param InStart table<string, boolean>
---@param InGoal GGoal
---@param InActions GAction[]
---@return string[]?
function GPlanner.Plan(InStart, InGoal, InActions)
    local startStates = InStart
    local goalStates = InGoal

    local openList = {} ---@type openNode[] 待扩展节点
    ---@class openNode
    local open = {
        States = startStates,
        Actions = {},
        f = 0, -- final最终代价
        g = 0, -- gained 当前代价
        h = 0, -- heuristic 预估代价
    }
    openList[1] = open
    local closedList = {} -- 已扩展过的节点

    local calc_limit = 100
    while #openList > 0 do
        calc_limit = calc_limit - 1
        if calc_limit < 0 then
            return log.error('循环次数超过限制!!!')
        end
        -- 选择Open集合中代价最小的状态
        table.sort(openList, function(a, b)
            return a.f < b.f -- ex: 再用h
        end)
        local curNode = table.remove(openList, 1) ---@type openNode

        -- 如果当前节点已经扩展, 则跳过
        if not GPlanner.IsNodeInClosedList(curNode, closedList) then
            if goap.util.is_state_cover(curNode.States, goalStates.DesiredStates) then
                return curNode.Actions
            end
            table.insert(closedList, curNode)
            -- 扩展所有可行的行动
            for _, action in ipairs(InActions) do
                if action:CanPerform(curNode.States) then
                    local newStates = action:ApplyEffect(table_util.deep_copy(curNode.States))

                    local newNode = {} ---@type openNode
                    newNode.States = newStates
                    newNode.h = goap.util.calc_no_cover_num(newStates, goalStates.DesiredStates)
                    newNode.g = curNode.g + action.ActionCost
                    newNode.f = newNode.h + newNode.g
                    newNode.Actions = table_util.deep_copy(curNode.Actions)
                    table.insert(newNode.Actions, action._ActionName)
                    table.insert(openList, newNode)
                end
            end
        end
    end
    return nil
end

---@public
---@param Node openNode
---@param ClosedList openNode[]
function GPlanner.IsNodeInClosedList(Node, ClosedList)
    for _, node in ipairs(ClosedList) do
        if node == Node then
            return true
        end
    end
    return false
end

return GPlanner