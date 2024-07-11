obj_util = {}

---@public 创建一个有Lua对象的UObject
obj_util.new_uobj = function()
    local ComObjClass = UE.UClass.Load('/Game/Ikun/Blueprint/Util/ComObj.ComObj_C')
    return UE.NewObject(ComObjClass)
end

return obj_util