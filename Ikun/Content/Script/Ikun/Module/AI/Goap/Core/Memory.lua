
---
---@brief   Goap的WorldState, 整个Agent的黑板
---@author  zys
---@data    Sat Sep 27 2025 20:41:12 GMT+0800 (中国标准时间)
---

---@class GMemory
---@field _State duplex<string, boolean>
local GMemory = class.class'GMemory' {
    _State = nil,
}

---@public
function GMemory:ctor()
    self._State = duplex.create()
end

---@public
---@param State string
---@param Value boolean
function GMemory:SetState(State, Value)
    self._State:dset(State, Value)
end

---@public
---@param State string
---@return boolean
function GMemory:GetState(State)
    return self._State:dfind(State)
end

---@public
---@return table<string, boolean>
function GMemory:GetStates()
    local tb = {}
    for _, k, v in self._State:diter() do
        tb[k] = v
    end
    return tb
end

function GMemory:Print()
    local str = ''
    for _, k, v in self._State:diter() do
        local config = ConfigMgr:GetConfig('State')[k]
        str = str..config.StateDesc..'='..(v and 'true' or 'false')..'|'
    end
    log.dev('qqq', str)
end

return GMemory