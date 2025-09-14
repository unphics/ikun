
---
---@brief   Team的基础信息; 还有消息传递解耦
---@author  zys
---@data    Sun Jul 06 2025 18:32:37 GMT+0800 (中国标准时间)
---

---@class TeamInfoClass: MdBase
---@field OwnerTeam TeamClass
---@field TeamId number
---@field bTeamLive boolean
---@field TeamMsgBus msgbus
local TeamInfoClass = class.class 'TeamInfoClass' : extends 'MdBase' {
--[[public]]
    ctor = function()end,
    Init = function()end,
    TeamInfoInitOnCreate = function()end,
--[[private]]
    OwnerTeam = nil,
    TeamId = nil,
    TeamMsgBus = nil
}

function TeamInfoClass:ctor(OwnerTeam)
    self.OwnerTeam = OwnerTeam
    self.TeamMsgBus = msg_bus.create()
end

function TeamInfoClass:Init()
end

---@public 创建时初始化一些信息
function TeamInfoClass:TeamInfoInitOnCreate(TeamId)
    self.TeamId = TeamId
    self.bTeamLive = true
end

---@public
function TeamInfoClass:TeamDestory()
    self.bTeamLive = false
end

---@public
function TeamInfoClass:TriggerTeamEvent(name, ...)
    self.TeamMsgBus:mtrigger(name, ...)
end

---@public
---@param name string
---@param obj any
---@param fn fun()
function TeamInfoClass:RegTeamEvent(name, obj, fn)
    self.TeamMsgBus:mreg(name, obj, fn)
end

---@public
---@param name string
---@param obj any
function TeamInfoClass:UnregTeamEvent(name, obj)
    self.TeamMsgBus:munreg(name, obj)
end

return TeamInfoClass