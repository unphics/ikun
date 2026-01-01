
---
---@brief   Lua侧网络系统(初版, 以后用熟练了再重构)
---@author  zys
---@data    Wed Dec 31 2025 19:20:06 GMT+0800 (中国标准时间)
---


local enet = require("enet")
local ffi = require("ffi")
local log = require("Core/Log/log")
local Protocols = require('System/Net/Protocols')

---@class NetSystem
---@param Host table
---@param Peer table
---@field IsServer boolean
---@field Handlers table
local NetSystem = {
    Host = nil,
    Peer = nil,
    IsServer = false,
    Handlers = {},
    FIXED_STEP = 0.033,
    accumulator = 0,
}

ffi.cdef[[
#pragma pack(push,1)
typedef struct {
    uint16_t msg_id; // 消息id
    uint16_t len; // 包体长度
    uint32_t seq; // 序列号
} net_header_t;
#pragma pack(pop)
]]

function NetSystem:StartServer(port)
    self.Host = enet.host_create("*:"..tostring(port), 32, 2)
    if self.Host == nil then
        -- 如果这里弹了 Error，说明端口绑定失败了！
        log.error("NetSystem", "FAILED TO CREATE HOST! Port " .. port .. " is probably occupied!")
        return false
    end
    self.IsServer = true
    log.info('NetSystem', 'Server start on port:'..port)
    return true
end

function NetSystem:StartClient(ip, port)
    self.Host = enet.host_create()
    self.Peer = self.Host:connect(ip..':'..port)
    self.IsServer = false
    log.info('NetSystem', 'Client connecting to '..ip..':'..port)
end

function ENetTick(dt, world)
    NetSystem:OnTick(dt, world)
end

---@param DeltaTime number
---@param InWorld UWorld
function NetSystem:OnTick(DeltaTime, InWorld)
    if not self.Host then
        return
    end

    -- 1. IO处理: 收包并分发
    while true do
        local event = self.Host:service(0)
        if not event or event.type == 'none' then
            break
        end
        self:HandleEvent(event)
    end

    -- 2. 逻辑处理: 固定步长驱动
    self.accumulator = self.accumulator + DeltaTime
    while self.accumulator >= self.FIXED_STEP do
        self:OnFixedUpdate(self.FIXED_STEP)
        self.accumulator = self.accumulator - self.FIXED_STEP
    end
end

function NetSystem:OnFixedUpdate(dt)
    -- 这里处理高频发包逻辑，如位置同步
end

-- 消息处理
function NetSystem:HandleEvent(event)
    if event.type == 'connect' then
        log.info('NetSystem', 'Peer connected: '..tostring(event.peer))
    elseif event.type == 'receive' then
        self:DispatchMessage(event.peer, event.data)
    elseif event.type == 'disconnect' then
        log.info('NetSystem', 'Peer disconnected:'..tostring(event.peer))
    end
end

-- 消息分发
function NetSystem:DispatchMessage(peer, data)
    if #data < ffi.sizeof('net_header_t') then
        return
    end

    -- 转换为ffi指针
    local header = ffi.cast('net_header_t*', data)
    local msg_id = header.msg_id

    local handler = self.Handlers[msg_id]

    if handler then
        -- 将数据指针偏移header大小, 传递给具体处理器
        local payload_ptr = ffi.cast('char*', data) + ffi.sizeof('net_header_t')

        local type_name = Protocols.ID_TO_TYPE[msg_id]
        local final_data = payload_ptr
        if type_name then
            final_data = ffi.cast(type_name..'*', payload_ptr)
        end
        
        handler(peer, payload_ptr, header)
    else
        log.warn("NetSystem", "No handler for MsgID: " .. msg_id)
    end
end

-- 注册处理
function NetSystem:Register(msg_id, func)
    self.Handlers[msg_id] = func
end

function NetSystem:Send(peer, msg_id, cdata_struct, reliable, seq)
    local flag = reliable and 'reliable' or 'unreliable'
    local struct_len = ffi.sizeof(cdata_struct)
    local header_len = ffi.sizeof('net_header_t')
    
    -- 构造header
    local header = ffi.new('net_header_t')
    header.msg_id = msg_id
    header.len = header_len + struct_len
    header.seq = seq or 0

    -- 合并数据
    -- todo 预分配一个足够大的ffi.new("char[2048]")缓冲区,  使用ffi.copy把Header和Body拷进去, 然后只调用一次ffi.string(buf, total_len)
    local packet_data = ffi.string(header, header_len)..ffi.string(cdata_struct, struct_len)
    peer:send(packet_data, 0, flag)
end

return NetSystem