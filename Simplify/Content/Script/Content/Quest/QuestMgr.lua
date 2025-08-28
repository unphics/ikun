
---
---@brief   任务系统
---@author  zys
---@data    Tue Aug 26 2025 19:41:08 GMT+0800 (中国标准时间)
---

require('Content/Quest/QuestStep')
require('Content/Quest/QuestInst')
require('Content/Quest/QuestGiver')
require('Content/Quest/QuestComp')

---@class QuestMgr : MdBase
---@field _QuestConfig_AcceptNpc table<number, QuestConfig[]>
---@field _QuestConfig_QuestId table<number, QuestConfig>
local QuestMgr = class.class 'QuestMgr' : extends 'MdBase' {
    ctor = function()end,
    Init = function()end,
    GetQuestConfigByAcceptNpc = function()end,
    _LoadAllQuestConfig = function()end,
    _QuestConfig_AcceptNpc = nil,
    _QuestConfig_QuestId = nil,
}

---@overide
function QuestMgr:ctor()
    self._QuestConfig_AcceptNpc = {}
    self._QuestConfig_QuestId = {}
end

---@overide
function QuestMgr:Init()
    self:_LoadAllQuestConfig()
end

---@public
---@return QuestConfig[]
function QuestMgr:GetQuestConfigByAcceptNpc(NpcCfgId)
    return self._QuestConfig_AcceptNpc[NpcCfgId] or {}
end

---@public
---@return QuestConfig[]
function QuestMgr:GetQuestConfigById(QuestId)
    return self._QuestConfig_QuestId[QuestId] or {}
end

---@private
function QuestMgr:_LoadAllQuestConfig()
    local allQuest = MdMgr.ConfigMgr:GetConfig('Quest') ---@type QuestConfig[]
    for _, quest in pairs(allQuest) do
        local acceptNpcId = quest.AcceptNpc
        if not self._QuestConfig_AcceptNpc[acceptNpcId] then
            self._QuestConfig_AcceptNpc[acceptNpcId] = {}
        end
        table.insert(self._QuestConfig_AcceptNpc[acceptNpcId], quest)

        self._QuestConfig_QuestId[quest.QuestId] = quest
    end
end

return QuestMgr