local EntityManager = {}

-- 预分配 10000 个单位的内存
-- 这是一块巨大的连续内存，Cache 极其友好
local MAX_COUNT = 10000
local entities = ffi.new("GameEntity[?]", MAX_COUNT)
local count = 0

-- 创建新单位
function EntityManager.Spawn(x, y, team)
    if count >= MAX_COUNT then return nil end
    
    local e = entities[count] -- 获取引用（其实就是指针）
    count = count + 1
    
    -- 初始化数据
    e.id = count
    e.pos.x = x
    e.pos.y = y
    e.stats.hp = 100
    e.state.team_id = team
    
    return e -- 返回这个 cdata 指针
end

-- 逻辑更新：这是 LuaJIT 最爽的地方
function EntityManager.Update(dt)
    -- 这是一个极度紧凑的循环
    -- JIT 会把它编译成类似 SIMD 的高效指令
    for i = 0, count - 1 do
        local e = entities[i]
        
        -- 1. 处理冷却
        if e.cd.q_cd > 0 then e.cd.q_cd = e.cd.q_cd - dt end

        -- 2. 简单的移动逻辑 (纯 Lua 计算)
        if e.state.is_moving then
            e.pos.x = e.pos.x + 1.0 * dt
        end

        -- 3. 死亡判定
        if not e.state.is_dead and e.stats.hp <= 0 then
            e.state.is_dead = true
            -- 可以在这里调用 UE 接口播放死亡特效
            -- UE.MyFuncLib.PlayEffect(e.pos.x, e.pos.y)
        end
    end
end

return EntityManager