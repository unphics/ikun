async_util = {}

async_util.delay = function (GameWorld, Time, Fn, ...)
    local co = coroutine.create(function (GameWorld, Time, ...)
        UE.UKismetSystemLibrary.Delay(GameWorld, Time)
        Fn(...)
    end)
    coroutine.resume(co, GameWorld, Time, ...)
end

return async_util