
---
---@biref   log
---@author  zys
---@data    Sun May 04 2025 14:19:28 GMT+0800 (中国标准时间)
---

---@class log
---@field key logkeys
local log = {}
log.key = require(ikf.setting.logkey_path)

---@public
function log.dev(...)
    ikf.setting.sys_error("[DEV]", ...)
end

---@public 日志
function log.log(...)
    ikf.setting.sys_print("[LOG]", ...)
end

---@public 细的调试信息, 记录变量值, 方法调用链路等细节; 生产环境通常关闭, 仅用于开发阶段定位问题
function log.debug(...)
    ikf.setting.sys_print("[DEBUG]", ...)
end

---@public 记录游戏运行的关键节点和正常状态(如登录, 场景加载完成, 系统启动等), 需保证信息对运维人员有意义且可读性强
function log.info(...)
    ikf.setting.sys_print("[INFO]", ...)
end

---@public 潜在异常单微营销核心功能(如配置文件缺失使用默认值, 网络延迟超过阈值, 资源加载超时重试), 需要后续关注但无需立即处理
function log.warn(...)
    ikf.setting.sys_warn("[WARN]", ...)
end

---@public 功能异常但游戏仍可运行(如数据库查询失败, 协议解析错误, 支付验证失败), 必须及时修复以避免问题扩大
function log.error(...)
    ikf.setting.sys_error("[ERROR]", ...)
end

---@public 导致游戏崩溃或服务终止的致命错误(如内存泄漏达到临界值, 关键线程死锁, 服务器集群失联), 需立即触发警告并人工干预
function log.fatal(...)
    ikf.setting.sys_error("[FATAL]", ..., debug.traceback())
end

return log