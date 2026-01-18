
--[[
-- -----------------------------------------------------------------------------
--  Brief       : 技能系统-表达式
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

ExpLib.Compile = function(InFormulaStr)
    if not InFormulaStr or InFormulaStr == '' then
        return nil, nil
    end

    -- 提取依赖, 建立反向索引
    local deps = {}
    local seen = {}
    for idStr in string.gmatch(InFormulaStr, "#(%d+)") do
        local id = tonumber(idStr)
        if not seen[id] then
            table.insert(deps, id)
            seen[id] = true
        end
    end

    -- 语法转换, 将#1011转换为(v[1011] or 0)
    local luaCode = string.gsub(InFormulaStr, "#(%d+)", "(v[%1] or 0)")

    -- 包装函数体
    local script = "return function(v) return "..luaCode.." end"

    -- 编译加载
    local chunk, err = loadstring(script, "FormulaChunk")
    if not chunk then
        log.warn(string.format("[FormulaError] 编译失败: %s\n原始公式:%s", err, InFormulaStr))
        return nil, nil
    end
    setfenv(chunk, Env)

    -- 执行chunk生成闭包
    local status, func = pcall(chunk)
    if not status then
        log.warn(string.format("[FormulaError] 生成闭包失败: %s", func))
        return nil, nil
    end
    return func, deps
end

return ExpLib