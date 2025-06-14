---
---@brief 影响力图
---@author zys
---@data Mon Mar 24 2025 01:13:06 GMT+0800 (中国标准时间)
---@desc 确定一个中心点构造一个范围内的影响力图,
---

---@class InfluenceItem
---@field Index number
---@field X number
---@field Y number
---@field Row number
---@field Col number

---@return InfluenceItem
local function MakeInfluenceItem(Index, X, Y, Row, Col)
    return {
        Index = Index,
        X = X,
        Y = Y,
        Row = Row,
        Col = Col,
    }
end

---@class InfluenceMapClass
---@field CenterV3 FVector 中心点
---@field ItemGridSize number 每个正方形格子的边长 -> 50
---@field HalfGridCount number 从大正方形Map中心点到边有多少格 -> 100
---@field InfluenceItems InfluenceItem[] 图
---@field CalcFns function<InfluenceItem,RoleClass,InfluenceMapClass>[]
local InfluenceMapClass = class.class 'InfluenceMapClass' {
--[[public]]
    ctor = function()end,
    AddCalcRoleCount = function()end,
    AddCustomCalc = function()end,
    AddRole = function()end,
    AddRoles = function()end,
    FindItemByXY = function()end,
    FindTheMostItemByFn = function()end,
--[[private]]
    InitGridItems = function()end,
    CheckPosInMapRange = function()end,
    DrawDebugSphere = function()end,
    CenterV3 = nil,
    ItemGridSize = nil,
    HalfGridCount = nil,
    InfluenceItems = nil,
    CalcFns = nil,
}
function InfluenceMapClass:ctor(Center, ItemGridSize, HalfGridCount)
    if not Center or not ItemGridSize or not HalfGridCount then
        log.error('InfluenceMapClass:ctor() : not Center or not ItemGridSize or not HalfGridCount !')
    end
    log.dev('影响力图初始化 !!!!!!')
    self.CenterV3 = Center
    self.CenterV3.X = self.CenterV3.X + 50
    self.CenterV3.Y = self.CenterV3.Y + 50
    self.ItemGridSize = ItemGridSize
    self.HalfGridCount = HalfGridCount
    self.CalcFns = {}
    self:InitGridItems()
end
---@private [Init] 根据CenterPos构建所有GridItem
function InfluenceMapClass:InitGridItems()
    self.InfluenceItems = {}
    local Count = self.HalfGridCount * self.HalfGridCount * 2 * 2
    local HalfSize = self.HalfGridCount * self.ItemGridSize -- 整个影响力图的半边长
    ---@note UEX轴向前,Y轴向右; 算出顶视图左上角第一个Item的左上角的坐标
    local FirstPosX = self.CenterV3.X + HalfSize
    local FirstPosY = self.CenterV3.Y - HalfSize
    -- 顶视图左上角第一个Item的中心坐标
    local FirstItemCenterX = FirstPosX - (self.ItemGridSize / 2)
    local FirstItemCenterY = FirstPosY + (self.ItemGridSize / 2)
    for i = 1, Count do
        local Row = (i - 1) // (self.HalfGridCount * 2)
        local Col = (i - 1) % (self.HalfGridCount * 2)
        local ItemCenterX = FirstItemCenterX - (self.ItemGridSize * Row)
        local ItemCenterY = FirstItemCenterY + (self.ItemGridSize * Col)
        -- self:DrawDebugSphere({ItemCenterX, ItemCenterY})
        local Item = MakeInfluenceItem(i, ItemCenterX, ItemCenterY, Row, Col)
        table.insert(self.InfluenceItems, Item)
    end
end
---@public [Calc] 添加人头数算子
function InfluenceMapClass:AddCalcRoleCount()
    ---@param InfluenceItem InfluenceItem
    ---@param Role RoleClass
    local function fn(InfluenceItem, Role, InfluenceMapClass)
        if not Role:IsRoleDead() then
            InfluenceItem.RoleCount = InfluenceItem.RoleCount + 1
        end
    end
    return self:AddCustomCalc(fn)
end
---@public [Calc] 添加自定义算子
---@param fnCalc function<InfluenceItem,RoleClass,InfluenceMapClass>
function InfluenceMapClass:AddCustomCalc(fnCalc)
    table.insert(self.CalcFns, fnCalc)
    return self
end
---@public [Add] 添加一个角色
---@param Role RoleClass
function InfluenceMapClass:AddRole(Role)
    if not Role or not Role.Avatar then
        return log.error('InfluenceMapClass:AddRole(): 输入参数错误')
    end
    -- 根据位置取出GridItem
    local Loc = Role.Avatar:K2_GetActorLocation()
    if not self:CheckPosInMapRange(Loc.X, Loc.Y) then
        return log.error('InfluenceMapClass:AddRole(): 不在范围内')
    end
    local InfluenceItem = self:FindItemByXY(Loc.X, Loc.Y)
    -- self:DrawDebugSphere({InfluenceItem.X, InfluenceItem.Y}, {0, 1, 0})
    for _, Fn in ipairs(self.CalcFns) do
        Fn(InfluenceItem, Role)
    end
end
---@private [Add] 检查位置在影响力图的范围内
function InfluenceMapClass:CheckPosInMapRange(X, Y)
    local HalfSize = self.HalfGridCount * self.ItemGridSize
    local bX = math.abs(self.CenterV3.X - X) < HalfSize
    local bY = math.abs(self.CenterV3.Y - Y) < HalfSize
    return bX and bY
end
---@public [Add] 添加一群角色
---@param Roles RoleClass[]
function InfluenceMapClass:AddRoles(Roles)
    for _, R in ipairs(Roles) do
        self:AddRole(R)
    end
end
---@public [Find] 根据位置查找Item
---@param LocX number
---@param LocY number
function InfluenceMapClass:FindItemByXY(LocX, LocY)
    local HalfSize = self.HalfGridCount * self.ItemGridSize -- 整个影响力图的半边长
    local FirstPosX = self.CenterV3.X + HalfSize
    local FirstPosY = self.CenterV3.Y - HalfSize
    local Row = (FirstPosX - LocX) // self.ItemGridSize
    local Col = (LocY - FirstPosY) // self.ItemGridSize
    local InfluenceItemIndex = (self.HalfGridCount * 2) * Row + Col + 1
    local InfluenceItem = self.InfluenceItems[InfluenceItemIndex]
    return InfluenceItem
end
---@public [Find] 查找最符合条件的Item
---@param Fn function(InfluenceItem):number
function InfluenceMapClass:FindTheMostItemByFn(Fn)
    
end
---@private [Debug]
function InfluenceMapClass:DrawDebugSphere(Pos, Color)
    Color = Color or {1, 0, 0}
    UE.UKismetSystemLibrary.DrawDebugSphere(world_util.GameWorld, UE.FVector(Pos[1], Pos[2], 100),
        self.ItemGridSize / 2, 8, UE.FLinearColor(Color[1], Color[2], Color[3]), 5, 2)
end

return InfluenceMapClass