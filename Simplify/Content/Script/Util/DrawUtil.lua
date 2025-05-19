
---@class DrawUtil
local tb = {}

tb.red = UE.FLinearColor(1, 0, 0)
tb.green = UE.FLinearColor(0, 1, 0)
tb.blue = UE.FLinearColor(0, 0, 1)

tb.draw_sphere = function(pos)
    local world = nil
    local loc = nil
    if pos.IsA then
        world = pos
        loc = pos:K2_GetActorLocation()
    else
        world = world_util.GameWorld
        loc = pos
    end
    UE.UKismetSystemLibrary.DrawDebugSphere(world, loc, 100, 12, UE.FLinearColor(0, 0, 1), 1.5, 4)
end

tb.draw_dir_sphere = function(pos1, pos2, color)
    local loc1 = pos1.IsA and pos1:K2_GetActorLocation() or pos1
    local loc2 = pos2.IsA and pos2:K2_GetActorLocation() or pos2
    local Color = color or UE.FLinearColor(1, 0, 0)
    local Duration = 2
    UE.UKismetSystemLibrary.DrawDebugSphere(world_util.GameWorld, loc2, 40, 12, Color, Duration, 5)
    UE.UKismetSystemLibrary.DrawDebugLine(world_util.GameWorld, loc1, loc2, Color, Duration, 5)
end

return tb