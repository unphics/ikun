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
async_util.timer = function(UObject, Fn, Time, bLoop)
    bLoop = bLoop or false
    local timer = UE.UKismetSystemLibrary.K2_SetTimerDelegate({UObject, Fn}, Time, bLoop, 0, 0)
    return timer
end

return async_util