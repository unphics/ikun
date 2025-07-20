
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

function log.log(...)
    print( ...)
end

function log.warn(...)
    UnLua.LogWarn(...)
end

function log.error(...)
    UnLua.LogError(...)
end

function log.dev(...)
    UnLua.LogError(...)
end

log.key = {
    luainit     = '[Lua初始化]',
    ueinit      = '[UE初始化]',
    roleinit    = '[角色初始化]',
    repos       = '[射手站位调整]',
    lich02boom  = '[Lich二技能]',
    beha        = '[行为选择]',
    support     = '[支援]',
    abp         = '[动画蓝图]'
}

log.error(log.key.luainit..' --------------------------------------------------------------------------')

return log