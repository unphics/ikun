
# 程序开发指引
```
author: zys
data: Sat Oct 18 2025 13:45:58 GMT+0800 (中国标准时间)
```
---
## 程序设计中建议的单位初始化顺序
1. 逻辑初始化(组织各种模块)
2. 数据初始化
3. 显示初始化
---
## 初始化
1. 考虑游戏初始化设计成由lua虚拟机拉起和组织的, 也就是由lua脚本拉起和组织的梯度初始化;比如组织一个用于初始化的回调包, 有十个函数表, 各个模块根据依赖关系注册到第n个表;例如全局的任务系统数据组织在第三个表注册，可以称为三环初始化
---
## 目录组织和模块组织
1. 同一个功能的或者同一个模块的放一起, 如任务的系统/玩家任务组件/Npc任务组件/任务实例/子任务/任务工具放一起
---
## 模块设计
1. 一定要用文本的形式先讲整个模块设计写下来, 再开始编码
---
## 英文名称简写对照表(addr)
|中文名称|英文名称|英文简写|
|-|-|-|
|管理器|manager|mgr|
|配置|config|cfg|
|定义|define|def|
|显示|display|disp|
|系数|correct|corr|
|默认|default|dft|
|位置|position|pos|
|计算|calculate|calc|
|分配|assign|asgn|
---
## UI开发
### 拖动
#### 双方都要覆写(由于接收拖动需要没有button, 故双方的点击等事件需要使用其他接口模拟)
```
---@private [Drag] OnPressed
function M:OnMouseButtonDown(MyGeometry, MouseEvent)
    return UE.UWidgetBlueprintLibrary.DetectDragIfPressed(MouseEvent, self, UE.EKeys.LeftMouseButton)
end
---@private [Drag] OnReleased
function M:OnMouseButtonUp(MyGeometry, MouseEvent)
end
---@private [Drag] OnHovered
function M:OnMouseEnter()
end
---@private [Drag] OnUnhovered
function M:OnMouseLeave()
end
```
#### 发起方覆写
```
---@private [Drag] 取消拖动: 在无法接收拖动的地方松手时触发回调
function M:OnDragCancelled()
end
---@private [Drag]  拖动发起
function M:OnDragDetected()
    if self.CanDrag then ---@notice user custom 检查数据和状态等
        local DragObjClass = UE.UClass.Load() -- 空类, 绑定lua就行
        local DragObj = UE.NewObject(DragObjClass, self)
        local DragWidgetClass = UE.UClass.Load()
        local DragWidget = UE.UWidgetBlueprintLibrary.Create(self, DragWidgetClass)
        DragWidget:OnConstruct() ---@notice user custom
        DragWidget:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
        DragObj.DefaultDragVisual = DragWidget
        DragObj.Pivot = UE.EDragPivot.CenterCenter
        DragObj.ItemValue = self.ItemValue -- @notice user custom 可以传递数据
        -- 拖动完成后拖拽物的回调
        DragObj.OnDrop:Add(self, function(Operation) end)
        -- 拖动中每帧执行
        DragObj.OnDragged:Add(self, function(Operation) end)
        -- 拖动取消
        DragObj.OnDragCancelled:Add(self, function(Operation) end)
        return DragObj
    else
        UE.NewObject(UE.UDragDropOperation, self)
    end
end
```
#### 接收方覆写
```
---@private [Drag] 拖动完成
function M:OnDrop(MyGeometry, PointerEvent, Operation)
    if Operation.ItemValue then -- 接收数据
        return true
    else
        return false
    end
end
```
---
## 游戏能力系统(GAS)
```
GA控制节奏和分段, GE控制数值和状态
UE.UAbilityTask_WaitGameplayTagAdded.WaitGameplayTagAdd()在服务端的更新有问题, 会先通知再改变数值, 所以不能用来写consume
GameplayAbility有发RPC的权力, 但是不能选InstancePerExec
```
---