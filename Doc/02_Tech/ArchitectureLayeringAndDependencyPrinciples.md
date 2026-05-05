# 架构中的结构分层与依赖关系处理原则
> **作者:** [zhengyanshuai]
> **创建日期:** Tue May 05 2026 17:05:16 GMT+0800 (中国标准时间)
> **最后更新:** Tue May 05 2026 17:05:16 GMT+0800 (中国标准时间)
> **文档状态:** 已实装
> **目标读者:** 程序
> **文档简介:** 给程序开发的架构设计提供参考
```
遗留问题:
    1. AI系统, 看一下我的GOAP为啥设计的时候不痛苦
    2. 是不是只要用接口交互一定不藕合或者一定不是混乱的设计
```
## 1. 问题背景
- 在设计复杂系统(例如Buff系统, 技能系统, AI系统)时, 经常会出现一种困惑:
    - 系统从结构上看是分层的
    - 但运行时又需要上下层交互
    - 于是容易出现"下层知道上层""互相知道"的现象
- 例如: Buff -> Effector -> Modifier
- 直觉上: Buff是上层, Effector是下层, Modifier是最底层
- 于是很多人会自然认为: 上层可以知道下层, 下层绝不能知道上层
- 但实际工程往往不这么简单
- 这份文档总结结构分层(StructureLayering)和依赖关系(DependencyDiraction)之间的区别, 以及如何处理多层系统中的运行时协作
## 2. 核心原则：结构层次 ≠ 依赖方向
- 这是最容易混淆的一点:
- 如Buff_Contains_Effector和Effector_Contains_Modifier
- 这是**结构上的拥有关系(Ownership/Containment)**
- 其表示:
    1. Buff由多个Effector组成
    2. Effector由多个Modifier组成
- 但不自动推导出依赖关系(Dependency): Buff -> Effect -> Modifier
- 更不意味着: Effector不能访问任何Buff信息
- 结构层次回答的是:
> 系统是由哪些部分组成的?
- 依赖关系回答的是:
> 某部分在运行时需要依赖哪些能力或信息
- 这是两张不同的图
## 3. Ownership(拥有关系)和Dependency(依赖关系)分离
### 3.1 Ownership
- Ownership表示谁管理谁的生命周期
- 例如:
    - Buff_Owns_Effector
    - Effector_Owns_Modifier
- 含义:
    - Buff 创建/销毁 Effector
    - Effector 创建/销毁 Modifier
- Ownership决定:
    - 生命周期
    - 内存归属
    - 组合关系
- 但不决定运行时访问权限
### 3.2 Dependency
- Dependency表示运行时逻辑需要哪些能力
- 例如:
    - Effect 需要读取 Stack
    - Effect 需要知道 Source/Target
    - Effect 需要刷新子效果时间
- 这意味着Effect需要依赖某些运行时上下文
- 但它不需要依赖Buff的具体实现
## 4. 错误做法: 直接依赖具体上层实现
- 错误示例:
```lua
function PoisonTickEffect:Execute(InBuffInst)
    local poisonBuff = InBuffInst
    poisonBuff.Timer = 0
    poisonBuff.InternalFoo()
end
```
- 问题:
    1. Effect知道具体Buff类型
    2. Effect修改Buff内部实现细节
    3. 强藕合
    4. 不满足开闭原则
- 后果:
    - Buff内部结构变化会破坏大量Effect
    - 新增Buff类型困难
    - Effect复用性差
## 5. 正确做法: 通过Context/Interface协作
- 核心思想:
> 下层不依赖上层实现, 而依赖上层暴露的抽象能力接口
- 例如:
```lua
function EffectContext:GetBuffState() end
function EffectContext:GetSource() end
function EffectContext:GetTarget() end
function EffectContext:GetRemainingTime() end
function EffectContext:RefreshSubeffect(Id) end
function PoisonTickEffect:Execute(EffectContext)
    local state = EffectContext:GetBuffState()
    ...
end
```
- 这时:
    - Effect不知道Buff内部实现
    - Effect只依赖运行时能力接口
- 依赖图变成: Buff -> Context <- Effect
- 而不是: Buff <-> Effect
## 6. Context的本质作用
- 很多系统里Context看起来只是"参数传递对象", 但实际上作用远大于此
- Context本质上是:
    - Runtime Facade
    - Adapter
    - Anti-Corruption Layer
- 它负责:
    - 隔离内部实现
    - 暴露受控能力
    - 稳定接口边界
- 例如:
    - Effect可以调用:
```lua
context:GetStackCount()
context:AddStack(...)
context:GetSubEffectRemaining(EffectorId)
```
    - 但不能访问:
```lua
buff.InternalTimers
buff.EffectorVector
buff.PrivateFields
```
- 这样Buff内部可以自由演化, 而Effector不受影响
## 7. 开闭原则在多层系统中的真正含义
- 很多人把开闭原则理解成: 下层绝不能知道上层
- 这其实过于机械
- 真正含义是:
> 对扩展开放，对修改关闭
- 也就是说:
    1. 新增一个 Effect 时，不应修改 Buff 内部实现
    2. Buff 内部重构时，不应破坏已有 Effect
- 实现方法不是完全隔离, 而是:
> 通过抽象接口协作
- 例如: 新增
```lua
function NewCrazyEffect:Execute(EffectContext)
end
```
- 不需要改Buff, 这就满足OCP
## 8. 推荐依赖方向
- 结构层: Buff_Owns_Effector, Effector_Owns_Modifier
- 运行时依赖: 
    - Effect -> IEffectContext
    - Modifier -> AttributeSystem
    - Buff -> Effector
- 或:
    - Buff_Owns_LifeCycle/State
    - Effect_DependsOn_IEffectContext
    - Modifier_DependsOn_AttributeSystem
- 重点: Ownership和Dependency是两套关系
## 9. 进一步细化: 权限分离(可选)
- 更复杂时, 可以拆多个context接口
- 例如: IStateReadContext, IStateWriteContext, ILifecycleContext这样不同Effect权限不同
- 例如:
    - 只读Effect: Class("DamageEffect", IStateReadContext)只能读
    - 刷新类Effect: Class("RefreshEffect", ILifecycleContext)可以刷新
    - 好处: 权限更清晰, 更易控制副作用
    - 缺点: 复杂度更高
    - 通常可以后期再做
## 10. 什么时候说明架构层次设计健康?
- 一个健康的多层系统通常具备:
    1. Ownership清晰: 谁创建谁, 谁销毁谁明确; 例如: Buff管Effect生命周期, Effect管Modifier生命周期
    2. Dependency稳定: 运行时依赖的是抽象接口, 而不是具体实现; 例如: Effect依赖Context, Modifier依赖AttributeSystem
    3. 层次职责明确:
        - Buff负责: 生命周期, 元信息, 高层抽象
        - Effect负责: 行为逻辑, 消费Context
        - Modifier负责: 数值修改
        - State负责: 数据存储
    4. 新增功能时尽量是“加代码”而不是“改代码”
        - 如新增一个新Effect: 添加类, 注册即可
        - 而不是: 改Buff核心逻辑,  改一堆switch-case
## 11. 常见误区
1. 把结构层级当成依赖层级
    - 错误: Buff是上层, 所以Effect绝不能知道任何Buff信息
    - 正确: 可以知道抽象能力, 不应依赖具体实现
2. 为了避免依赖而禁止任何协作
    - 结果: 下层什么都拿不到, 系统只能靠全局变量或奇怪hack传信息, 更糟糕
3. 直接暴露整个上层对象
    - 例如: Effect:Execute(InBuff), 会导致下层看到过多实现细节
4. 过早极端接口拆分
    - 一开始就拆十几个context接口
    - 后果: 维护成本高, 简单需求也复杂
    - 建议: 先统一Context, 后期按需要拆权限
## 12. 最后总结
> **结构分层描述"由谁组成", 依赖关系描述"运行时需要什么能力", 两者不是同一件事**
- 因此:
    - 下层可以依赖上层提供的抽象能力
    - 不应依赖上层具体实现细节
- 也可以压缩成一句记忆:
> **Ownership决定谁管理谁, Dependency决定谁需要谁的能力**
- 不要把这两件事混在一起