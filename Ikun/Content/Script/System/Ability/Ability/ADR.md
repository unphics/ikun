# ADR:Ability模块

现状:
- AbilityManager:
    - 作用: 能力/技能管理器, 持有能力和技能的配置表, 管理技能的生命周期
    - 字段:
        _SkillList: 活跃的技能列表
        _AbilityConfigData: 能力配置表
        _SkillConfigData: 技能配置表
    - 方法:
        InitAbilityManager: 初始化能力管理
        _LoadConfig: 加载能力和技能的配置表
        TickAbilityManager: 更新技能对象
        AcquireSkill: 分配一个技能对象
        ReleaseSkill: 结束技能对象
        LookupAbilityConfig: 查看能力配置
        LookupSkillConfig: 查看技能配置
- Ability:
    - 作用: 处理广义上技能的冷却/消耗/伤害评估等与过程无关内容
    - 字段:
        