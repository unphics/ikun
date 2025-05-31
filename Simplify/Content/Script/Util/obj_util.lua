
---
---@brief UE的UObject相关的工具方法
---@author zys
---@data Sun May 04 2025 14:17:18 GMT+0800 (中国标准时间)
---

local obj_util = {}

---@public 创建一个有Lua对象的UObject
obj_util.new_uobj = function()
    local ComObjClass = UE.UClass.Load('/Game/Ikun/Blueprint/Util/ComObj.ComObj_C')
    return UE.NewObject(ComObjClass)
end

---@param UObject UObject
obj_util.is_valid = function(UObject)
    if UObject then
        return UE.UKismetSystemLibrary.IsValid(UObject)
    end
    return false
end

---@param UObject UObject
obj_util.dispname = function(UObject)
    return obj_util.is_valid(UObject) and UE.UKismetSystemLibrary.GetDisplayName(UObject) or 'InValidObject'
end

return obj_util