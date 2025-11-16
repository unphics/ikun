
---@class GoapUtil
local GoapUtil = class.class'GoapUtil'{}

---@public
---@param BaseStates table<string, boolean>
---@param TargetStates table<string, boolean>
---@return boolean
GoapUtil.is_key_cover = function(BaseStates, TargetStates)
    for name, value in pairs(TargetStates) do
        if BaseStates[name] == nil then
            return false
        end
    end
    return true
end

---@public 检查BaseStates是否满足TargetStates的要求
---@param BaseStates table<string, boolean>
---@param TargetStates table<string, boolean>
---@return boolean
GoapUtil.is_state_cover = function(BaseStates, TargetStates)
    for name, value in pairs(TargetStates) do
        local v = BaseStates[name]
        if v ~= value then
            return false
        end
    end
    return true
end

---@public 计算未覆盖的数量
---@param BaseStates table<string, boolean>
---@param TargetStates table<string, boolean>
GoapUtil.calc_no_cover_num = function(BaseStates, TargetStates)
    local num = 0
    for name, value in pairs(TargetStates) do
        if BaseStates[name] ~= value then
            num = num + 1
        end
    end
    return num
end

---@public
---@param Config table<string, string>
---@return table<string, boolean>
GoapUtil.make_states_from_config = function(Config)
    local tb = {}
    for k, desc in pairs(Config) do
        tb[k] = desc == 'true' and true or false
    end
    return tb
end

return GoapUtil