
---@class goap_util
local goap_util = {}

---@public
---@param BaseStates table<string, boolean>
---@param TargetStates table<string, boolean>
---@return boolean
goap_util.is_key_cover = function(BaseStates, TargetStates)
    for name, _ in pairs(TargetStates) do
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
goap_util.is_state_cover = function(BaseStates, TargetStates)
    for name, value in pairs(TargetStates) do
        if BaseStates[name] ~= value then
            return false
        end
    end
    return true
end

---@public 计算未覆盖的数量
---@param BaseStates table<string, boolean>
---@param TargetStates table<string, boolean>
goap_util.calc_no_cover_num = function(BaseStates, TargetStates)
    local num = 0
    for name, value in pairs(TargetStates) do
        if BaseStates[name] ~= value then
            num = num + 1
        end
    end
    return num
end

return goap_util