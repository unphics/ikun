
---
---@brief   动作
---@author  zys
---@data    Thu Sep 25 2025 23:40:32 GMT+0800 (中国标准时间)
---

---@class ActionConfig
---@field ActionKey string
---@field ActionName string
---@field ActionDesc string
---@field ActionTemplate string
---@field Preconditions table<string, string>
---@field Effects table<string, string>
---@field Cost number

---@class GAction
---@field _ActionName string 名字
---@field ActionCost number 花费 config
---@field Preconditions table<string, boolean> config
---@field Effects table<string, boolean> config
---@field _ActionStart boolean
---@field _ActionEnd boolean
---@field _ActionSucceed boolean
local GAction = class.class'GAction' {}

---@public [Config]
function GAction:ctor(Agent, Name, Preconditions, Effects, Cost)
    self._ActionName = Name or 'Action'
    self.Preconditions = Preconditions or {}
    self.Effects = Effects or {}
    self.ActionCost = Cost or 1
    log.info('赋予Action', Name, rolelib.role(Agent):RoleName())
end

---@public [Config]
---@param BaseStates table<string, boolean>
---@return table<string, boolean>
function GAction:ApplyEffect(BaseStates)
    for state, value in pairs(self.Effects) do
        BaseStates[state] = value
    end
    return BaseStates
end

---@public [Config]
---@param CurStates table<string, boolean>
function GAction:CanPerform(CurStates)
    for state, expect in pairs(self.Preconditions) do
        if self.Preconditions[state] == true then
            if not CurStates[state] or CurStates[state] ~= expect then
                return false
            end
        else
            if CurStates[state] ~= nil and CurStates[state] ~= expect then
                return false
            end
        end
    end
    return true
end

---@public [Runtime] 开始
---@param Agent GAgent
function GAction:ActionStart(Agent)
    self._ActionStart = true
end

---@public [Runtime]
---@param Agent GAgent
function GAction:ActionTick(Agent, DeltaTime)
end

---@public [Runtime] 结束
---@param Agent GAgent
---@param bSuccess boolean
function GAction:ActionEnd(Agent, bSuccess)
end

---@protected [Runtime] do end
---@param bSuccess boolean
function GAction:EndAction(bSuccess)
    self._ActionEnd = true
    self._ActionSucceed = bSuccess
end

---@public [Runtime] 意外取消
---@param Agent GAgent
function GAction:ActionCancelled(Agent)
end

---@public [Runtime]
function GAction:ResetActionState()
    self._ActionSucceed = false
    self._ActionStart = false
    self._ActionEnd = false
end

---@public [Pure]
---@return boolean
function GAction:IsActionSucceed()
    return self._ActionSucceed
end

---@public [Pure]
---@return boolean
function GAction:IsActionEnd()
    return self._ActionEnd
end

---@public [Pure]
---@return boolean
function GAction:IsActionStart()
    return self._ActionStart
end

---@public [Pure]
---@return string
function GAction:GetActionName()
    return self._ActionName
end

return GAction