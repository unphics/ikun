
---
---@brief   初始化顺序管理
---@author  zys
---@data    Tue Sep 23 2025 11:13:55 GMT+0800 (中国标准时间)
---

local log = require('Core/Log/log')

local ring = {
    init_star = 'init_star',
    init_quest = 'init_quest',
    init_loc = 'init_loc',
    init_site = 'init_site',
    init_bag_comp = 'init_bag_comp',
    init_role = 'init_role',
    open_dft_ui = 'open_dft_ui',
}

local groups = {
    env_init = {
        ring.init_star,
        ring.init_quest,
    },
    gm_init = {
        ring.init_loc,
    },
    ctl_init = {
        ring.init_site,
    },
    ctl_delay_1 = {
        ring.init_role,
        ring.open_dft_ui,
    },
    ctl_delay_2 = {
        ring.init_bag_comp,
    }
}

---@class gameinit
---@field private _initring table
local gameinit = {}
gameinit._initring = {}
gameinit.groups = groups
gameinit.ring = ring

for _, keys in pairs(groups) do
    for _, key in ipairs(keys) do
        gameinit._initring[key] = {}
    end
end

---@public
---@param callback fun(table)
gameinit.registerinit = function(ring, obj, callback)
    local infos = gameinit._initring[ring]
    table.insert(infos, {obj = obj, callback = callback})
    if infos._inited then
        callback(obj)
    end
end

---@public
gameinit.triggerinit = function(group)
    for _, key in ipairs(group) do
        local infos = gameinit._initring[key]
        log.info(log.key.gameinit, 'triggerinit', key)
        for _, info in pairs(infos) do
            if type(info) == "table" and info.callback and info.obj then
                info.callback(info.obj)
            end
        end
        infos._inited = true
    end
end

return gameinit