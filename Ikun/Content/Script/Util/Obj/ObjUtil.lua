obj_util = {}

obj_util.new_uobj = function()
    local ComObjClass = UE.UClass.Load('/Game/Ikun/Blueprint/Util/ComObj.ComObj_C')
    return NewObject(ComObjClass)
end

return obj_util