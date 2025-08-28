
---
---@brief   任务组件
---@author  zys
---@data    Thu Aug 28 2025 22:43:09 GMT+0800 (中国标准时间)
---

---@class QuestCompClass
---@field _Owner RoleClass
local QuestCompClass = class.class 'QuestCompClass' {
    ctor = function()end,
    _Owner = nil,
}

function QuestCompClass:ctor(Owner)
    self._Owner = Owner
end


return  QuestCompClass