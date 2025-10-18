
---
---@brief   UELua开发的Log工具
---@author  zys
---@data    Sun May 04 2025 14:19:28 GMT+0800 (中国标准时间)
---

---@class log
---@field tb_log table<string, number>
---@field tb_warn table<string, number>
---@field tb_error table<string, number>
local log = {}

log.lua_log_head = ' *******'

---@public 临时的通用print
function log.log(...)
    IkunLog( log.lua_log_head, ...)
end

---@public 不打印
function log.no(...)
end

---@public 临时的开发用红色print
function log.dev(...)
    IkunError(log.lua_log_head, '[DEV]', ...)
end

---@public 最详细的调试信息, 记录变量值, 方法调用链路等细节; 生产环境通常关闭, 仅用于开发阶段定位问题
---@rule ikun中可以提交debug到版本分支
function log.debug(...)
    IkunLog( log.lua_log_head, '[DEBUG]', ...)
end

---@public 记录游戏运行的关键节点和正常状态(如登录, 场景加载完成, 系统启动等), 需保证信息对运维人员有意义且可读性强
function log.info(...)
    IkunLog( log.lua_log_head, '[INFO]', ...)
end

---@public 潜在异常单微营销核心功能(如配置文件缺失使用默认值, 网络延迟超过阈值, 资源加载超时重试), 需要后续关注但无需立即处理
function log.warn(...)
    IkunWarn(log.lua_log_head, '[WARN]', ...)
end

---@public 功能异常但游戏仍可运行(如数据库查询失败, 协议解析错误, 支付验证失败), 必须及时修复以避免问题扩大
function log.error(...)
    IkunError(log.lua_log_head, '[ERROR]', ...)
end

---@public 导致游戏崩溃或服务终止的致命错误(如内存泄漏达到临界值, 关键线程死锁, 服务器集群失联), 需立即触发警告并人工干预
function log.fatal(...)
    IkunError(log.lua_log_head, '[FATAL]', ...)
    IkunError(' ↑↑↑↑↑↑↑↑', debug.traceback())
end

function log.fmt84(num)
    return string.format('%08.4f', num)
end
function log.fmt54(num)
    return string.format('%05.4f', num)
end

log.key = {
    luainit     = '[Lua初始化]',
    ueinit      = '[UE初始化]',
    roleinit    = '[角色初始化]',
    repos       = '[射手站位调整]',
    lich02boom  = '[Lich二技能]',
    beha        = '[行为选择]',
    support     = '[支援]',
    abp         = '[动画蓝图]',
    archer01    = '[弓箭手一技能]',
    sceneinit   = '[场景初始化]',
    Chat        = '[对话]', -- 对话界面, 对话模块, 交互模块(任务是否也同)
    item        = '[物品]',
}

log.error('\n======================================================================================================================================================\n=================================================================='..log.key.luainit..'==================================================================\n======================================================================================================================================================')

return log