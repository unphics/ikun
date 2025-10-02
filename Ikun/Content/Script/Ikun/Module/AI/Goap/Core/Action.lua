
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
---@field Preconditions table<string, boolean>
---@field Effects table<string, boolean>
---@field Cost number

---@class GAction
---@field _ActionName string 名字
---@field ActionCost number 花费
---@field Preconditions table<string, boolean>
---@field Effects table<string, boolean>
local GAction = class.class'GAction' {}

---@public
function GAction:ctor(Name, Preconditions, Effects, Cost)
    self._ActionName = Name or 'Action'
    self.Preconditions = Preconditions or {}
    self.Effects = Effects or {}
    self.ActionCost = Cost or 1
end

---@public
---@param BaseStates table<string, boolean>
---@return table<string, boolean>
function GAction:ApplyEffect(BaseStates)
    for state, value in pairs(self.Effects) do
        BaseStates[state] = self.Effects[state]
    end
    return BaseStates
end

---@public
---@param CurStates table<string, boolean>
function GAction:CanPerform(CurStates)
    for state, expect in pairs(self.Preconditions) do
        if CurStates[state] ~= expect then
            return false
        end
    end
    return true
end