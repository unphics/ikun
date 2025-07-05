
---
---@brief 一些通用的黑板键定义
---@author zys
---@data Tue May 06 2025 14:26:22 GMT+0800 (中国标准时间)
---

---@class BBKeyDef
local Key = {
    BBNewBTKey = 'BBNewBTKey',              -- 角色新行为树的Key
    FightTarget = 'FightTarget',            -- 角色战斗目标
    MoveTarget = 'MoveTarget',              -- 角色的移动目标
    SelectAbility = 'SelectAbility',        -- 选择的准备使用的技能

    FightPosLoc = 'FightPosLoc',            -- 战斗位置坐标
    UrgentMoveTarget = 'UrgentMoveTarget',  -- 紧急移动的目标

    SupportTarget = 'SupportTarget',        -- 支援目标(治疗,加buff等)

    LastBehav = 'LastBehav',                -- 上一个行为
    CurBehav = 'CurBehav',                  -- 当前行为
    NextBehav = 'NextBehav',                -- 下一个行为
    Standing = 'Standing',                  -- 站住, 不移动
    MoveBehavObj = 'MoveBehavObj',          -- 移动行为的对象
    SafeLoc = 'SafeLoc',                    -- 安全区
}

return Key