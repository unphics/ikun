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

历史记录
- 2026-02-10 基础落地
  - 时效：Instant / HasDuration / Infinite
  - Tick：统一 FixedUpdate 驱动；基类不持有时间调度状态
  - Tag：Granted / Block / Cancel（激活添加、移除回收；拦截；互斥取消）
  - 字段：BuffSource / BuffTarget 私有 + getter
  - 构造：参数式优先（保留旧表式兼容）
  - 叠加：不在基类；玩法侧脚本钩子实现
