
---
---@brief   Npc任务组件
---@author  zys
---@data    Wed Aug 27 2025 10:39:38 GMT+0800 (中国标准时间)
---@desc    挂在Npc(或交互物)身上, 提供与任务系统的交互入口; 可以接取/交付任务
---

---@class QuestGiverClass
---@field _Owner RoleClass
local QuestGiverClass = class.class 'QuestGiverClass' {
    ctor = function()end,
    _AvaiableQuestList = nil,
    _Owner = nil,
}

function QuestGiverClass:ctor(Owenr)
    self._Owenr = Owenr
end



return QuestGiverClass