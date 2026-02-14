# ADR: Buff 模块

- 状态：Accepted

现状
- 时效：Instant / HasDuration / Infinite
- Tick：统一 FixedUpdate 驱动；基类不持有时间调度状态
- Tag：Granted / Block / Cancel（激活添加/移除回收；拦截；互斥取消）
  	- GrantedTags：Buff 激活时授予给目标的标签；用于标识当前状态或能力（例如 buff.speedup）。在 Buff 移除时对应回收。父级标签计数同样随之增加/减少（见 TagContainer）。
  	- BlockTags：施加前检查目标是否包含这些标签；命中则拒绝施加（TryApply 阶段返回 Blocked）。常用于免疫、占用、控制中等拦截场景；父级标签命中也视为拦截。
  	- CancelTags：施加前执行互斥取消；当目标命中这些标签时，先移除命中的互斥 Buff，再施加当前 Buff。用于互斥组或同类效果替换。父级标签命中同样触发取消。
- 字段：BuffSource / BuffTarget 私有 + getter
- 构造：参数式优先（保留旧表式兼容）
- 叠加：不在基类；玩法侧脚本钩子实现
- BuffManager:
	- 作用: 加载Buff相关配置
	- 字段: _BuffConfigs, 
	- 方法: _LoadBuffConfig, LookupBuffConfig, TickBuffManager, 
- BuffBase:
	- BuffKey, BuffDuration, _StartTime, _EndTime
	- 作用: 处理Buff的实际修改作用, 处理Buff重入(未定)
	- 方法: CanApplyBuff, ApplyBuff, TickBuff, DeactivateBuff, ReapplyBuff, IsBuffExpired
- BuffContainer:
	- 作用: Part上的Buff容器, 
	- 字段: _Buffs, 
	- 方法: AddBuff, 
- AbilityPart:
	- 作用: 角色在技能系统下的代理
	- 方法: MakeBuff, TryApplyBuffToSelf

历史记录
- 2026-02-10 基础落地
  	- 时效：Instant / HasDuration / Infinite
  	- Tick：统一 FixedUpdate 驱动；基类不持有时间调度状态
  	- Tag：Granted / Block / Cancel（激活添加、移除回收；拦截；互斥取消）
  	- 字段：BuffSource / BuffTarget 私有 + getter
  	- 构造：参数式优先（保留旧表式兼容）
  	- 叠加：不在基类；玩法侧脚本钩子实现
- 2026-02-11 抽象BuffContainer类
  - 原因: 为了后续扩展Buff系统，抽象出BuffContainer类，用于管理Buff的添加、移除、查询等操作。
- 2026-05-14 Buff刷新问题
  	- 问题: 当目标被施加了任意一个buff的时候, 又被施加了一个相同的buff, 那么会有几种情况? 其中: 目标肯定是同一个, 源不一定是同一个.
		- 1.持续时间重置
		- 2.层数叠加
		- 3.持续时间延长
		- 4.覆盖
		- 5.无效(原Buff有唯一性)
		- 6.独立存在
		- 7.其他特殊机制