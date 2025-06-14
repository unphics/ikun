
---
---@brief 基于UE的一些异步工具方法
---@author zys
---@data Sun May 04 2025 14:21:36 GMT+0800 (中国标准时间)
---

---@class async_util
local async_util = {}


---@param GameWorld UWorld
---@param Time number
---@param Fn function
async_util.delay = function (GameWorld, Time, Fn, ...)
    local co = coroutine.create(function (GameWorld, Time, ...)
        UE.UKismetSystemLibrary.Delay(GameWorld, Time)
        Fn(...)
    end)
    coroutine.resume(co, GameWorld, Time, ...)
end

---@param UObject UObject
---@param Fn function
---@param Time number
---@param bLoop boolean
---@return FTimerHandle
async_util.timer = function(UObject, Fn, Time, bLoop)
    bLoop = bLoop or false
    local timer = UE.UKismetSystemLibrary.K2_SetTimerDelegate({UObject, Fn}, Time, bLoop, 0, 0)
    return timer
end

---@param UObject UObject
---@param handle FTimerHandle
async_util.clear_timer = function(UObject, handle)
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(UObject, handle)
    handle = nil
end

return async_util