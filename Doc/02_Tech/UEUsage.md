# UE使用
> **作者:** [zhengyanshuai]
> **创建日期:** Sun Apr 12 2026 16:08:25 GMT+0800 (中国标准时间)
> **最后更新:** Sun Apr 12 2026 16:08:25 GMT+0800 (中国标准时间)
> **文档状态:** 已实装
> **目标读者:** 程序
> **文档简介:** 给开发人员的UE使用提供参考
## 动画部分
- 使用自带Rotate_to_face_BB_entry任务时需勾选Chr的UseControllerRotationYaw, 同时开启Chr下的ChrMovementComp的UseControllerDesiredRotation
## 运行编辑器
- 以AsClient模式运行时, 需打开EditorPreferences的LaunchSeparateServer
- 多编辑器运行时要勾掉UseLessCPUWhenInBackground, 否则会导致服务器高ping
## UI开发-拖动
### 双方都要覆写()
```
由于接收拖动需要没有button, 故双方的点击等事件需要使用其他接口模拟
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
### 发起方覆写
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
### 接收方覆写
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