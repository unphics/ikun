---
---@brief   任务
---@author  zys
---@data    Wed Aug 27 2025 10:50:42 GMT+0800 (中国标准时间)
---

---@class QuestConfig
---@field QuestId number
---@field Title string
---@field Desc string 
---@field BeginStep number
---@field AcceptNpc number
---@field CompleteNpc number
---@field PreQuest number[]
---@field NextQuest number[]
---@field Repeatable number
---@field ExpireTime number
---@field RewardId number

---@class QuestInstClass
local QuestInstClass = class.class 'QuestInstClass' {
   
}

return QuestInstClass