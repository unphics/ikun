
# 程序开发指引
```
author: zys
data: Sat Oct 18 2025 13:45:58 GMT+0800 (中国标准时间)
```
---
## 当前开发目录组织
```
VscodeWorkspace:
Doc/: 游戏文档
Config/: 游戏配置文件
    Area/: 游戏中的世界地理地貌地形相关配置, 如所有的物理地点配置等
    Camera/: 玩家摄像机相关配置, 如普通/瞄准等状态的相机位置旋转FOV配置等
    District/: 游戏中的世界行政地区相关配置, 如国家/村庄等
    Goap/: 游戏的AI解决方案是采用的GoalOrientedActionPlan, 相关的State/Goal/Action等在此配置
    Item/: 游戏的物品配置
    Quest/: 任务相关配置
    Role/: 角色相关配置
    Skill/: 技能相关配置, 如Skill/Effect/TargetActor等
    Talk/: 对话相关配置
    GlobalConst: 全局一些常量配置, 如游戏速度等
    Preload: 需要预加载的配置表在此注册
Script/: 游戏的所有lua脚本文件
    Content/: 游戏的不与UE对象绑定的纯业务脚本
        Area/: 地理地貌相关脚本, 包含Cosmos/Location/Site/Star等类
        Chat/: 对话功能, 包含NpcChat/ChatExecLib/ChatCondLib等类
        District/: 行政地区, 包含City/Village/Kingdom等类
        Item/: 物品, 包含ItemBase/Bag/ItemMgr等
        Quest/: 任务系统, 包含QuestInst/QuestMgr/QuestComp/QuestTool等
        Role/: 角色, 包含Role/RoleMgr/RoleInfo/RoleLib等
    Ikun/: 与UE对象绑定的业务脚本
        Actor/: 包含BP_House/BP_Stall等
        Blueprint/
            AIC/: AIController类及其组件
            Comp/: Actor的组件
            GAS/: GAS所有模板文件, 有Ability/Cue/EffectCalc/TargetActor等文件夹
            PC/: PlayerController类及其组件
        Chr/: 人形类及其组件
        Module/: 使用UE但是不和UE对象绑定的lua脚本
            AI/: AI解决方案, 包含一套行为树实现和一套GOAP实现, 及其所有业务脚本
            Config/: 配置表管理器
            Input/: UE增强输入应用层模块
            Nav/: 寻路
    Util/: 工具类, 如str/table/net/math/gas/log等
```
---
## 当前游戏角色相关组件配置
```
BP_IkunPC 玩家控制器
    InteractComp 检测玩家注视Npc, 请求进入交互状态, 标记玩家进入交互状态
    ChatComp 为对话模块和对话UI提供网络互通接口
    CameraViewComp 相机
BP_ChrBase 角色基类
    RoleComp 角色组件
    AnimComp 动画组件
    InFightComp 战斗状态组件, 入战状态/武备状态
    SkillComp 技能组件
    BP_BagComp 背包组件
BP_NpcBase: BP_ChrBase Npc角色基类
    BP_ReceptionComp Npc接待玩家组件
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
## 模块组织
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
## 新的工程组织
```
Script/
    Framework/: 资源加载/数据表格/网络/日志/界面/
        Core/
            Init 框架入口
            Class OOP实现
            Log 日志
            ObjectPool 对象池
            Config 配置
            Version 版本号
            Duplex 双容器
        System/
            File
            Network
        DataTable
    System/
        GOAP
        Nav: 路径缓存
    Module/

    Ikun/
```
---