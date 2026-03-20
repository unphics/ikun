# 程序开发指引
> **作者:** [zhengyanshuai]
> **创建日期:** Sat Oct 18 2025 13:45:58 GMT+0800 (中国标准时间)
> **最后更新:** Fri Mar 20 2026 21:36:05 GMT+0800 (中国标准时间)
> **文档状态:** 已实装
> **目标读者:** 所有程序
## 当前游戏角色相关组件配置
- BP_IkunPC 玩家控制器
    - InteractComp 检测玩家注视Npc, 请求进入交互状态, 标记玩家进入交互状态
    - ChatComp 为对话模块和对话UI提供网络互通接口
    - CameraViewComp 相机
- BP_ChrBase 角色基类
    - BP_RoleRegisterComp 角色组件
    - AnimComp 动画组件
    - InFightComp 战斗状态组件, 入战状态/武备状态
    - SkillComp 技能组件
    - BP_BagComp 背包组件
- BP_NpcBase: BP_ChrBase Npc角色基类
    - BP_ReceptionComp Npc接待玩家组件
## 程序设计中建议的单位初始化顺序
1. 逻辑初始化(组织各种模块)
2. 数据初始化
3. 显示初始化
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
## 程序设计
**模式概念:**
|模式|关系|
|-|-|
|继承|建立'是一个'的关系, 有限的继承可以提升开发效率|
|组合|建立'有一个'的关系|
|接口|建立'能做什么'的契约, 如IInteractable|
|ECS|数据与行为分离|
## 编码
### 命名
|部分|编码风格|
|-|-|
|类名|大驼峰|
|方法名|大驼峰|
|成员变量|大驼峰|
|文件名|大驼峰|
|临时变量|小驼峰|
### 文件头
- 时间格式转换工具: https://www.lddgo.net/convert/datetime-format-converter
## VsCode插件
|插件|说明|
|-|-|
|EmmyLua|Lua调试, Lua开发智能提示|
|Reload|重启VsCode|
|SynthWave'84|常用主题|
|EditCSV|好用的csv查看与编辑插件|
## 动画部分
- 使用自带Rotate_to_face_BB_entry任务时需勾选Chr的UseControllerRotationYaw, 同时开启Chr下的ChrMovementComp的UseControllerDesiredRotation
## 框架参考
- https://github.com/EllanJiang/GameFramework
- https://passion.blog.csdn.net/article/details/109259806
- https://passion.blog.csdn.net/article/details/109262711
- https://passion.blog.csdn.net/article/details/110206648
- https://passion.blog.csdn.net/article/details/129754833
- https://passion.blog.csdn.net/article/details/110248405
## 运行编辑器
- 以AsClient模式运行时, 需打开EditorPreferences的LaunchSeparateServer
## UI开发
### 拖动
#### 双方都要覆写()
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