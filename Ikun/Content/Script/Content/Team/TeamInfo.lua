
---
---@brief   Team的基础信息; 还有消息传递解耦
---@author  zys
---@data    Sun Jul 06 2025 18:32:37 GMT+0800 (中国标准时间)
---

---@class TeamInfoClass
---@field _OwnerTeam TeamClass
---@field _TeamId number
---@field bTeamLive boolean
---@field _TeamMsgBus msgbus
local TeamInfoClass = class.class 'TeamInfoClass' {
    ctor = function()end,
    TeamInfoInitOnCreate = function()end,
    TeamDestory = function()end,
    TriggerTeamEvent = function()end,
    RegTeamEvent = function()end,
    UnregTeamEvent = function()end,
    bTeamLive = nil,
    _OwnerTeam = nil,
    _TeamId = nil,
    _TeamMsgBus = nil
}

---@public
---@param OwnerTeam TeamClass
function TeamInfoClass:ctor(OwnerTeam)
    self._OwnerTeam = OwnerTeam
    self._TeamMsgBus = msg_bus.create()
end

---@public 创建时初始化一些信息
function TeamInfoClass:TeamInfoInitOnCreate(TeamId)
    self._TeamId = TeamId
    self.bTeamLive = true
end

---@public
function TeamInfoClass:TeamDestory()
    self.bTeamLive = false
end

---@public
function TeamInfoClass:TriggerTeamEvent(name, ...)
    self._TeamMsgBus:mtrigger(name, ...)
end

---@public
---@param name string
---@param obj any
---@param fn fun()
function TeamInfoClass:RegTeamEvent(name, obj, fn)
    self._TeamMsgBus:mreg(name, obj, fn)
end

---@public
---@param name string
---@param obj any
function TeamInfoClass:UnregTeamEvent(name, obj)
    self._TeamMsgBus:munreg(name, obj)
end

return TeamInfoClass