# 游戏技能系统文档
```
author: zys
data: Sat Oct 18 2025 14:48:57 GMT+0800 (中国标准时间)
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
|Hit|受击|无|
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