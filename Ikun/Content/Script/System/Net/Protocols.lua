
---
---@brief   Protocols
---@author  zys
---@data    Thu Jan 01 2026 08:02:35 GMT+0800 (中国标准时间)
---

local ffi = require('ffi')

---@class Protocols
local Protocols = {}

Protocols.MSG = {
    -- 系统(1 - 100)
    PING = 1,
    PONG = 2,

    -- 玩家业务 (101 - 200)
    LOGIN_REQ = 101,
    LOGIN_RSP = 102,

    -- 游戏同步 (201 - 300)
    PLAYER_MOVE = 201,
    SPAWN_ACTOR = 202,
}

ffi.cdef [[
#pragma pack(push, 1)
    // 心跳
    typedef struct {
        uint32_t timestamp;
    } msg_ping_t;

    // 登录请求
    typedef struct {
        uint32_t user_id;
        char token[32];
    } msg_login_req_t;
    
    // 移动同步
    typedef struct {
        uint32_t entity_id;
        double x, y, z;
        double pitch, yaw, roll;
    } msg_player_move_t;
#pragma pack(pop)
]]

Protocols.ID_TO_TYPE = {
    [Protocols.MSG.PING] = "msg_ping_t",
    [Protocols.MSG.PONG] = "msg_ping_t",
    [Protocols.MSG.LOGIN_REQ] = "msg_login_req_t",
    [Protocols.MSG.PLAYER_MOVE] = "msg_player_move_t",
}

return Protocols