---
---@brief Role的Lich(阿巴克)特化, 见人就砍！
---@author zys
---@data Tue Jan 28 2025 00:06:09 GMT+0800 (中国标准时间)
---

---@class R_Lich_3: RoleBaseClass
local R_Lich_3 = class.class 'R_Lich_3' : extends 'RoleBaseClass' {
    IsEnemy = function()end,
}
function R_Lich_3:IsEnemy(OtherRole)
    return true
end