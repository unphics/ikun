
---
---@brief   任务系统
---@author  zys
---@data    Tue Aug 26 2025 19:41:08 GMT+0800 (中国标准时间)
---

---@class QuestMgr : MdBase
local QuestMgr = class.class 'QuestMgr' : extend 'MdBase' {
--[[public]]
    ctor = function()end,
    Init = function()end,
    Tick = function(DeltaTime)end,
--[[private]]
}

---@overide
function QuestMgr:ctor()
end

---@overide
function QuestMgr:Init()
end

---@overide
function QuestMgr:Tick(DeltaTime)
end


return QuestMgr