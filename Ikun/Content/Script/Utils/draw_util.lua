
---@class draw_util
local draw_util = {}

draw_util.red = UE.FLinearColor(1, 0, 0)
draw_util.green = UE.FLinearColor(0, 1, 0)
draw_util.blue = UE.FLinearColor(0, 0, 1)
draw_util.white = UE.FLinearColor(1, 1, 1)

draw_util.draw_sphere = function(pos, radius)
    radius = radius or 100
    local world = nil
    local loc = nil
    if pos.IsA then
        world = pos
        loc = pos:K2_GetActorLocation()
    else
        world = world_util.World
        loc = pos
    end
    UE.UKismetSystemLibrary.DrawDebugSphere(world, loc, radius, 12, UE.FLinearColor(0, 0, 1), 1.5, 4)
end

draw_util.draw_dir_sphere = function(pos1, pos2, color)
    local loc1 = pos1.IsA and pos1:K2_GetActorLocation() or pos1
    local loc2 = pos2.IsA and pos2:K2_GetActorLocation() or pos2
    color = color or UE.FLinearColor(1, 0, 0)
    local Duration = 2
    UE.UKismetSystemLibrary.DrawDebugSphere(world_util.World, loc2, 40, 12, color, Duration, 5)
    UE.UKismetSystemLibrary.DrawDebugLine(world_util.World, loc1, loc2, color, Duration, 5)
end

return draw_util