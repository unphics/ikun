### Combat System Architecture Decision Record (战斗系统架构决策记录)
```
定位: 简洁描述模块的核心职责和他的作用
意义: 解释为什么这个模块在系统中不可或缺
职责: 列出模块主要功能或任务
构成: 
与其他模块关系: 简要说明该模块如何与其他模块交互
```
# 战斗系统草案:
```
普适需求:
    派生属性: 每1点力量增加5点生命上限和2点攻击力
    临时属性: 伤害不修改Health而是修改一个名为IncomingDamage的隐藏属性, 检测到IncomingDamage变化时: 触发护盾抵扣->减伤->无敌判断->扣除血量->IncomingDamage清零
    周期性与生命周期控制: 持续10秒每秒扣血; 永久生效直到被驱散; 一次一瞬间的伤害
    复杂的叠加规则: 毒可以叠5层, 每层独立计时; 点燃再次施加时刷新时间不增加层数; 怒气叠满10层自动变成'狂暴'状态
    标签互动与状态互斥: 开了无敌就不能中流血; 使用了净化药水, 移除所有毒类型的Buff; 处于眩晕技能无法使用位移技能
    属性依赖与快照: 造成施法者攻击力50%的伤害; 根据目标当前已损失生命值造成额外伤害; 施法瞬间攻击力是多少, 后续流血就按多少算(快照)
解决方法:
    多来源毒层重入:
        一个周期效果器打底, 然后第一层正常应用, 第二层在Reapply中打包Source信息压入层级队列, 每帧全部刷时间, 时间结束从队列头弹出, 具体效果自己处理(如: for队列每层获取Source信息,处理后走伤害计算流程)
属性集:
    字段: Attrs, Modifiers, DirtyMask
    配置: Formula, bInstantModify, bInstantPostChanged
属性修改器:
    字段: ModId, AttrKey, ModOp, ModValue, EffectId
效果器:
    字段: EffectId, Modifiers, BelongBuff, PeroidTime, DurationTime, Source, Target
增益:
    字段: Effects
    配置: MainEffect
伤害:
    配在效果器中, 应用时执行计算, 结束后丢出数据包Handle, 以修改器的形式作用在IncomingDamage上, 在OnPostChanged中处理伤害应用并且发消息把数据包丢出去并且清Handle数据
    这样的话就需要一个DamageManager, 还能做集中数据分析
内存:
    50个属性就是50个i32, 就是200B, 加上一个i64的mask就是208B
    Modifier(ModId-u32,AttrKey-u8,ModOp-u8,ModValue-i32,ModSource-u32,sum-14B对齐到16B), 预留50个就是800B
    1000个人就是1MB
```
# 战斗系统
- 战斗系统包含的模块: 属性, 技能, 伤害, 效果, 增益, 事件, 目标, 标记
# 属性模块
- 定位: 描述单位在当前时刻的数值状态
- 意义: 提供一个稳定/可扩展/可依赖分析的数值状态系统
- 职责:
    - 存储基础属性, 计算派生属性, 管理属性之间的依赖关系, 接收并应用属性修改, 对外提 供当前最终属性值
- 构成:
    - AttrSet(属性集): 属性集合; 持久存在, 提供最终属性读取, 内部动态更新, 添加与移除属性修改器
    - AttrManager(属性管理器): 管理属性的定义规则与依赖结构, 属性的规则层; 加载属性配置, 解析属性公式, 建立属性依赖关系, 生成属性集实例
    - AttrModifieer(属性修改器): 对某一属性施加影响的一个数值变更单元, 一条对属性的修改规则
- 与其他模块的关系:
    - 与技能: 技能读取属性, 技能不修改属性结构, 技能通过Modifier影响属性
    - 与效果器: 增益持有Modifier, 增益将Modifier添加到属性集, AttrSet负责数值更新
    - 与Damage: Damage读取属性, Damage不改变属性公式
- 内容:
    - AttrSet:
        - GetAttributeValue(InAttrKey)
        - AddModifier(InModifier)
        - RemoveModifier(InModifier)
        - AddDirty(InAttrKey)
        - RemoveDirty(InAttrKey)
        - IsDirty(InAttrKey)
    - AttrManager:
        - CreateAttrSet(InSets)
        - AcquireModifier(InAttrKey, InModOp, InModValue, InModSource)
        - ReleaseModifier(InModifier)
        - GetAttrFormula(InAttrKey)
        - GetAttrDependencies(InAttrKey)
        - GetAttrDependents(InAttrKey)
# 效果模块
- 定位: 一段时间内周期性得影响和修改单位的属性与状态
- 意义: 实现一个数据驱动/可扩展/基础功能充足的效果器模块
- 职责: 触发与执行效果, 管理效果的组合与优先级, 数据驱动, 管理周期性与持续时间
- 构成: 
- 与其他模块关系:
概念:
    Effector: 影响角色状态的基础修改单位
# 技能模块
- 定位: 管理与执行技能相关的所有行为
- 意义: 
概念:
    Ability(能力):
        - 简介: 一项技能的综合; 可以持有一些技能, 如火球术能力持有发射火球和火球爆炸技能; 负责处理冷却和消耗等; 持久存在
        - 数据: 
    Skill(技能): 一些行为序列的集合; 每次技能触发时实例化技能
# Buff模块
概念:
    Buff(增益): 给角色添加一些持续性的复合影响
# 组件模块
- 概念:
    Part(相当于组件): 其他单位的战斗能力的体现, 包含能力数组/Buff容器/属性集等数据和对应功能
