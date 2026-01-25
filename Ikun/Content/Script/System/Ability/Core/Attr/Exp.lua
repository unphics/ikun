
--[[
-- -----------------------------------------------------------------------------
--  Brief       : 能力系统-表达式
--  File        : Exp.lua
--  Author      : zhengyanshuai
--  Date        : Sun Jan 18 2026 13:41:39 GMT+0800 (中国标准时间)
--  Description : 表达式解析
--  Todo        : 考虑重新设计封装
--  License     : MIT License
-- -----------------------------------------------------------------------------
--  Copyright (c) 2026 zhengyanshuai
-- -----------------------------------------------------------------------------
--]]

local ExpLib = {}

-- 允许策划在表达式里使用的函数
local Env = {
    min = math.min,
    max = math.max,
    clamp = function(v, min, max) return math.max(min, math.min(max, v)) end,
}

-- 防止策划访问_G
setmetatable(Env, {
    __index = function(t, k)
        return nil
    end,
})

ExpLib.CollectDeps = function(InFormulaStr)
    if not InFormulaStr or InFormulaStr == '' then
        return nil
    end

    -- 提取依赖, 建立反向索引
    local deps = {}
    local seen = {}
    for idStr in string.gmatch(InFormulaStr, "#([%w_]+)") do
        local id = tonumber(idStr) or idStr
        if not seen[id] then
            table.insert(deps, id)
            seen[id] = true
        end
    end
    return deps
end

ExpLib.Compile = function(InFormulaStr)
    if not InFormulaStr or InFormulaStr == '' then
        return nil
    end

    -- 语法转换, 将#1011转换为(v[1011] or 0)
    local luaCode = string.gsub(InFormulaStr, "#(%d+)", "(v[%1] or 0)")

    -- 包装函数体
    local script = "return function(v) return "..luaCode.." end"

    -- 编译加载
    local chunk, err = loadstring(script, "FormulaChunk")
    if not chunk then
        log.warn(string.format("[FormulaError] 编译失败: %s\n原始公式:%s", err, InFormulaStr))
        return nil
    end
    setfenv(chunk, Env)

    -- 执行chunk生成闭包
    local status, func = pcall(chunk)
    if not status then
        log.warn(string.format("[FormulaError] 生成闭包失败: %s", func))
        return nil
    end
    return func
end

---@todo zys: 回头仔细研究一下
ExpLib.TopoSortDFS = function(InAttrDeps)
    -- visited: 永久标记，表示这个节点已经完全处理完毕
    local visited = {}
    -- tempMarked: 临时标记，表示这个节点正在处理中（用于检测环）
    local tempMarked = {}
    -- 结果数组（最终会包含排序后的节点）
    local result = {}

    -- 1. 首先收集所有节点（因为有些节点只出现在依赖关系中，不一定是key）
    local allNodes = {}
    for node, deps in pairs(InAttrDeps) do
        allNodes[node] = true
        for _, dep in ipairs(deps) do
            allNodes[dep] = true
        end
    end
    
    -- 2. 核心递归函数
    local function visit(node)
        -- 如果节点被临时标记，说明我们在一个环中（循环依赖）
        if tempMarked[node] then
            error("发现循环依赖！节点: " .. node)
        end
        
        -- 如果节点没有被永久标记（处理完成）
        if not visited[node] then
            -- 标记为"正在处理"
            tempMarked[node] = true
            
            -- 关键点：递归处理所有依赖这个节点的节点
            -- 例如：如果node = C，attrDeps[C] = {"D"}，表示C被D依赖
            -- 所以我们需要先处理D，再处理C
            if InAttrDeps[node] then
                for _, neighbor in ipairs(InAttrDeps[node]) do
                    visit(neighbor)  -- 递归处理依赖者
                end
            end
            
            -- 移除临时标记
            tempMarked[node] = nil
            -- 标记为已处理完成
            visited[node] = true
            
            -- 关键：将节点插入结果数组的开头！
            -- 为什么插入开头？因为我们是从后往前构建结果的
            table.insert(result, 1, node)
        end
    end
    
    -- 3. 遍历所有节点开始DFS
    for node, _ in pairs(allNodes) do
        if not visited[node] then
            visit(node)
        end
    end
    
    return result
end

return ExpLib