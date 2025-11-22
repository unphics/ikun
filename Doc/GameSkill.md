# 游戏技能系统文档
```
author: zys
data: Sat Oct 18 2025 14:48:57 GMT+0800 (中国标准时间)
```
---
## 技能系统设计
```
Skill部分:
    需求:
        1. 流程控制与输入交互
            按住蓄力, 松开释放; 按下开始引导, 被打断或移动则停止; 连按三下攻击键, 播放三段不同的攻击动作
            GAS的WaitInputRelease/WaitInputPress/WaitGameplayEvent
        2. 资源与冷却
            消耗50法力, 冷却10秒; 消耗当前生命值的20%; 拥有3个连击点才能使用
            GAS的CostGEClass/CooldownGEClass/CommitAbility
        3. 目标获取
            鼠标指向的敌人; 屏幕中心的敌人; 自身周围5米内所有友军; 火球撞到的第一个敌人
        4. 动画与位移
            冲锋; 跳劈; 施法前摇不能动, 后摇可以取消
            GAS的PlayAnimAndWait/ApplyRootMotionMoveToForce
        5. 实例化策略
            这个被动永远在后台跑; 每次按火球都生成一个新的技能实例
            GAS的InstancePolicy
    案例:
        1. 连续点按攻击键播放1->2->3段攻击动作, 如果在第1段动作结束前没按键则重置回第1段
        2. 按住按键开始蓄力, 角色减速, 松开按键发射箭矢, 蓄力越久伤害越高, 有最大上限
        3. 按下按键持续消耗法力对周围造成伤害, 松开按键或被打断停止
        4. 向角色面前方向快速冲刺一段距离, 冲刺期间免疫伤害, 且穿过敌人
        5. 当角色受到近战攻击时自动对攻击者造成反伤
Buff部分:
    需求:
        1. 周期性与生命周期控制:
            持续10秒每秒扣血; 永久生效直到被驱散; 一次一瞬间的伤害
            GAS的DurationPolicy和Period周期
        2. 复杂的叠加规则:
            毒可以叠5层, 每层独立计时; 点燃再次施加时刷新时间不增加层数; 怒气叠满10层自动变成'狂暴'状态
            GAS的StackType和Overflow溢出处理
        3. 标签互动与状态互斥
            开了无敌就不能中流血; 使用了净化药水, 移除所有毒类型的Buff; 处于眩晕技能无法使用位移技能
            GAS的GrantedTags给拥有者标签,ImmunityTags免疫这些标签的GE,RemoveGEWithTags溢出这些标签的GE,BlockedAbilityTags禁止这些标签的技能
        4. 属性依赖与快照:
            造成施法者攻击力50%的伤害; 根据目标当前已损失生命值造成额外伤害; 施法瞬间攻击力是多少, 后续流血就按多少算(快照)
            GAS的MagnitudeCalc, Snapshot
        5. 赋予能力:
            捡起这把枪获得射击技能; 变身成恶魔原有技能替换为一套新技能
            GAS的GrantedAbilities
    案例:
        1. 喝下药水, 10秒内每秒恢复50点生命值, 如果受到伤害则回复效果被打断
        2. 开启技能后攻击力翻倍, 但护甲降低50%, 持续无限时间, 直到手动关闭或法力耗尽
        3. 斩杀伤害, 顺发, 如果目标血量低于20%, 造成3倍伤害, 否则1倍伤害
        4. 角色变成冰块, 无法移动, 无法施法, 但免疫所有伤害, 并移除身上所有负面效果
        5. 获得一个500点的护盾, 受到伤害时优先扣护盾, 然后扣血
Target部分:
    需求:
        1. 闪电链:
            击中第一个目标后寻找500内最近的另一个目标, 重复N次
        2. 复杂的地面预选:
            释放地刺时, 玩家按住技能键出现一个指示器, 指示器必须叠合地形起伏, 且不能在墙体内部
            需要物理检测Trace和贴花(Decal), 甚至需要根据法线判断坡度是否太陡
Attribute部分:
    需求:
        1. 派生属性:
            每1点力量增加5点生命上限和2点攻击力
            GAS的PreAttributeChange/PostGEExecute
        2. 临时属性:
            伤害结算: 在GAS中通常不会直接修改Health而是修改一个IncomingDamage的隐藏属性
            当检测到IncomingDamage变化时: 触发护盾抵扣->减伤->无敌判断->扣除Health->IncomingDamage清零
Tag部分:
    需求:
        1. 层级判定:
            免疫火系伤害; 免疫元素伤害 免疫所有伤害
            定义Damage.Elemental.Fire/Damage.Elemental.Ice
        2. 状态机模拟:
            角色不能同时处于施法中和被眩晕状态
            定义State.Casting/State.Stunned
            互斥规则(TagRelationship全局配置):当State.Stunned时移除State.Casting
Cue部分:
    需求:
        1. 参数驱动的材质变化
            一个石化buff, 随着时间推移, 角色的皮肤材质从正常慢慢变成石头, buff结束前闪烁几次
        2. 同类型特效聚合
            如果一个Boss同时中了100个流血buff, 不要生成100个cue而是把特效变大
            Cue收到OnActive时先检查该Actor身上是否有同类型Cue, 有就不生成, 而是增加现有Cue计数或强度
技能系统开发顺序:
    1. AttributeSet和GameplayTag(前20%时间)
        必须先行
        先定好有几种抗性? 几种状态? 伤害公式流程?
    2. GameplayAbility和GameplayEffect(中间60%时间)
        日常搬砖根据策划案一个个做
    3. Target和Cue(穿插其中)
        Target先写几个通用的(射线/圆圈/扇形)
        Cue可以先用占位符(红球等)
```
---
## 属性定义
|分类|属性名|显示名|描述|
|-|-|-|-|
|**Health**|Health|血量|当前生命值|
||MaxHealth|最大血量|生命值上限|
|**Attack**|AttackPower|攻击力|物理攻击强度|
||Stamina|耐力值|当前耐力|
||MaxStamina|最大耐力值|耐力上限|
|**Mana**|Mana|魔法值|当前魔法值|
||MaxMana|最大魔法值|魔法值上限|
||MagicPower|魔法攻击力|魔法攻击强度|
|**Regon**|HealthRegen|生命回复|生命恢复速度|
||ManaRegen|魔法回复|魔法恢复速度|
||StaminaRegen|耐力回复|耐力恢复速度|
|**Defense**|PhysicalDefense|物理防御|减少受到的物理伤害|
||MagicalDefense|魔法防御|减少受到的魔法伤害|
|**Combat**|Accuracy|命中率|攻击命中概率|
||Evasion|闪避率|闪避攻击概率|
||CriticalChance|暴击率|造成暴击的概率|
||CriticalResist|暴击抗性|降低被暴击的概率|
|**Move**|MoveSpeed|移动速度|角色移动速度|
|**Survival**|Hunger|饥饿值|随时间减少，影响其他属性|
||Fatigue|疲劳值|活动消耗，影响命中率等|
||Thirst|饮水值|消耗快，过低会掉血|
||Sanity|精神值|环境影响，过低会幻听失控|
---
## 角色技能操作构建
|技能槽位|技能描述|键位|
|-|-|-|
|Equip|入战|R|
|UnEquip|出战|R|
|Dodge|瞬移|Shift|
|NormalOne|技能一|MouseLeft|
|NormalTwo|技能二|MouseRight|
|OnHit|受击|无|
|Special|特殊技能|Z|
---
## 技能分类
### 1. 按触发方式 (Trigger)
- **主动技能 (Active)**
- **被动技能 (Passive)**
### 2. 按使用场景/功能性 (Usage)
- **战斗技能 (Combat)**
- **生活技能 (Life)**
- **表现技能 (Cinematic)**
  - 入战 (Equip)
  - 出战 (UnEquip)
- **系统技能 (System)**
  - 死亡处理 (Death)
  - 复活 (Revive)
  - 切换职业
### 3. 按表现形式 (Performance)
- 近战技能 (Melee)
- 远程技能 (Ranged)
- 投射物技能 (Projectile)
- 范围技能 (AOE)
- 持续技能 (OverTime)
- 召唤技能 (Summon)
- 位移技能 (Movement)
- 控制技能 (CrowdControl)
- 转换技能 (Transform，切换形态)
- 辅助技能 (Auxiliary)
### 4. 按目标对象 (Target)
- 自我 (Self)
- 单体 (SingleTarget)
- 群体 (Multi)
- 环境 (Env)
- 链式 (Chain)
### 5. 按逻辑特征/技术实现 (Logic)
- **即时技能 (Instance)**
- **引导技能 (Channel)**: 需要持续施法
- **蓄力技能 (Charged)**: 按住输入键充能，释放后强度不同
- **组合技能 (Combo)**: 按一定顺序释放形成连招
- **开关型技能 (Toggle)**: 开启后持续，手动关闭
- **被动触发技能 (Proc)**: 概率或条件触发
### 6. 按资源消耗类型 (Cost)
- 法力值 (Mana)
- 体力值 (Stamina)
- 冷却时间 (CooldownOnly)
- 物品 (Item)
- 无消耗 (Free)
### 7. 按技能归属 (Source)
- 职业技能 (Class)
- 通用技能 (Common)
- 种族/血统技能 (Racial/Lineage)
- 装备技能 (Equipment)
- 任务技能 (Quest)
### TargetActor 分类
- 点目标 (Point)
- 范围目标 (Area)
- 投射物目标 (Projectile)
- 链式目标 (Chain)
- 复合目标 (Composite)
### GameplayTag 设计
```
Skill (技能)
    Slot(槽位)
        Equip
        UnEquip
        Dodge
        NormalOne
        NormalTwo
        OnHit
        Special
    Type (类型)
        Trigger (触发)
            Active (主动技能)
            Passive (被动技能)
        Usage (使用场景)
            Combat (战斗技能)
            Life (生活技能)
            Cinematic (表现技能)
                Equip (入战)
                UnEquip (出战)
            System (系统技能)
                Death (死亡)
                Revive (复活)
        Performance (表现形式)
            Melee
            Ranged
            Projectile
            AOE
    Action (动作, 技能的阶段与动作步骤)
        Start (技能开始)
        Cast (释放动作)
        Charge (蓄力中)
            Hold (维持)
            Max (满蓄力)
        Release (释放)
        Fire (发射)
        Hit (命中)
        Finish (结束)
        Cancel (被打断)
    State (状态, 技能的状态)
        Charging
        Casting
        Cooldown
        Active
        ToggledOn
        Diabled (被沉默)
    Effect
```
---