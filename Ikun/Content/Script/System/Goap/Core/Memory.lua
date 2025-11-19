
---
---@brief   Goap的WorldState, 整个Agent的黑板
---@author  zys
---@data    Sat Sep 27 2025 20:41:12 GMT+0800 (中国标准时间)
---

---@class GMemory: AgentPartInterface
---@field _State table<string, boolean>
local GMemory = class.class'GMemory' {
    _State = nil,
}

---@public
function GMemory:ctor(OwnerAgent)
    self._OwnerAgent = OwnerAgent
    self._State = {}
end

---@public
---@param State string
---@param Value boolean
function GMemory:SetState(State, Value)
    self._State[State] = Value
end

---@public
---@param State string
---@return boolean
function GMemory:GetState(State)
    return self._State[State]
end

---@public
---@return table<string, boolean>
function GMemory:GetStates()
    local tb = {}
    for k, v in pairs(self._State) do
        tb[k] = v
    end
    return tb
end

---@public
function GMemory:Print(bPrintAll)
    local str = ''
    for k, v in pairs(self._State) do
        local config = ConfigMgr:GetConfig('State')[k]
        if not config then
            log.error('GMemory:Print()', '未配置的状态', '\''..k..'\'')
        end
        if bPrintAll or v then
            str = str..config.StateDesc..'='..(v and 'true' or 'false')..'|'
        end
    end
    log.info(rolelib.role(self):RoleName(), '打印当前记忆::'..str)
end

return GMemory