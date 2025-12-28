# 游戏AI(仅战斗)-GOAP方案

## 概述
使用GOAP作为AI解决方案最大的原因是规划器不像_(描述行为树状态机)等在构建起一个树后一个Task的增删都会引起大片树的重新设计
## 主要概念
1. Memory
2. Sense
3. Goal
4. Agent
5. Action
6. Planner
7. Executor
## 业务情景
### 战斗
- 对于一个普通的野外怪物的战斗业务来用GOAP解构, 基本设计为: Sense感知到有敌军后, 发出Goal没有敌军, 然后触发Action判断有敌军就
    选择一个敌人作为Focus和新增一个Goal敌人死亡, 然后再次触发Plan, 计划出选择技能然后移动和放技能, 一轮攻击结束再进行下一轮. 
    具体设计如下
1. Sense
    EnemySense: 
        从仇恨值系统中监控有敌军存活, 设置HasEnemy
        如果没有敌军, 设置HasEnemy=false
        当HasEnemy变为true时, 新增Goal
    FocusSense: 
        实时监控当前Focus的存活状态, 距离角度等
        更新FocusDinstance, IsFacingFocus
2. Memory
    HasEnemy
    HasFocus
    ReadSkill
    IsPositioned
    IsFacingFocus
    FocusDistance
    FocusDead
4. Goal
    ClearEnemy
    KillFocus
3. Action
    SelectFocus(HasEnemy=true;HasFocus=false,FocusDead=false): 如果没敌军则成功, 否则选择一个当做Focus, 新增Goal目标死亡
    SelectSkill(HasFocus=true;ReadSkill=true)
    MoveToPosition(ReadSkill=true;IsPositioned=true)
    TurnToFocus(IsPositioned=true;IsFacingFocus=true)
    ActiveSkill(ReadySkill=true,IsFacingFocus=true;FocusDead=true,IsPositioned=false)
    ConfirmKill
目前设计可以支撑一个中等复杂度的怪物AI, 高复杂度还需: 掩体(Cover), 压制(Suppressed), 绕后(Flank), 实时动态风险评估, 团体AI, 士气, 连招等