
--[[
-- -----------------------------------------------------------------------------
--  Brief       : RoleBaseClass
--  File        : RoleBase.lua
--  Author      : zhengyanshuai
--  Date        : Sun Nov 09 2025 09:27:37 GMT+0800 (中国标准时间)
--  Description : 角色系统-角色的基类
--  License     : MIT License
-- -----------------------------------------------------------------------------
--  Copyright (c) 2025-2026 zhengyanshuai
-- -----------------------------------------------------------------------------
--]]

local NpcChat = require("Content/Chat/NpcChat")
require('System/Role/RoleHoldLocation')

---@class RoleConfig
---@field RoleId number
---@field RoleName string
---@field RoleDesc string
---@field bUniqueRole boolean
---@field BelongKingdom number
---@field RoleSkills number[]
---@field GoapKey string
---@field RoleChat number[]
---@field HoldLocations number[]

---@class RoleBaseClass
---@field public Avatar BP_ChrBase UE表演对象
---@field public Bag BagClass 背包
---@field public QuestComp QuestCompClass 角色的任务, 预计处理 todo zys
---@field public QuestGiver QuestGiverClass, 预计处理 todo zys
---@field public HoldLocation RoleHoldLocationClass todo zys 角色持有的地点
---@field public NpcChat NpcChatClass
---@field private _RoleId integer
---@field private _RoleCfgId integer
---@field private _RoleName string
---@field private _BelongKingdom Kingdom 所属国家
local RoleBaseClass = class.class'RoleBaseClass' {}

---@override
function RoleBaseClass:ctor()
    self.Avatar = nil
    self.HoldLocation = nil
    self._BelongKingdom = nil
    self._RoleId = -1
    self._RoleCfgId = -1
    self._RoleName = '未命名'
    
    self.Bag = class.new'BagClass'(self)
    self.QuestComp = class.new 'QuestCompClass'(self)
    self.QuestGiver = class.new 'QuestGiverClass'(self)
    self.Bag = class.new 'BagClass'(self)
    self.NpcChat = class.new 'NpcChatClass'(self)
end

---@override
---@param DeltaTime number
function RoleBaseClass:RoleTick(DeltaTime)
    if self.Agent then
        -- self.Agent:TickAgent(DeltaTime)
    end
end

---@public [Init-Step1]
---@param InRoleCfgId integer
---@param InConfig RoleConfig
function RoleBaseClass:InitBaseInfo(InRoleCfgId, InConfig)
    self._RoleCfgId = InRoleCfgId
    self._RoleName = InConfig.RoleName
    self._RoleId = -1
    
    local DistrictMgr = Cosmos:GetStar().DistrictMgr ---@type DistrictMgr
    self._BelongKingdom = DistrictMgr:FindKingdomByCfgId(InConfig.BelongKingdom) ---@type Kingdom
end

---@public [Init-Step2] 复杂组件初始化. 此阶段已有有效的实例ID.
function RoleBaseClass:InitComplexPart()
    local config = RoleMgr:GetRoleConfig(self._RoleCfgId) ---@type RoleConfig

    self.HoldLocation = class.new 'RoleHoldLocationClass'(self, self._RoleCfgId)

    if not str_util.is_empty(config.GoapKey) then
        local agent = class.new 'GAgent' (self) ---@as GAgent
        self.Agent = agent
    end
end

---@public
---@param InAvatarChr BP_ChrBase
function RoleBaseClass:SetAvatar(InAvatarChr)
    self.Avatar = InAvatarChr
end

---@public 半夜刷新调用
function RoleBaseClass:LateAtNight()
    if self.Agent then
        self.Agent:LateAtNight()
    end
end

---@public
---@return integer
function RoleBaseClass:GetRoleId() -- const
    return self._RoleId
end

---@public
---@return integer
function RoleBaseClass:GetRoleCfgId() -- const
    return self._RoleCfgId
end

---@public
---@return string
function RoleBaseClass:RoleName() -- const
    return self._RoleName
end

---@public
---@return Kingdom
function RoleBaseClass:GetBelongKingdom() -- const
    return self._BelongKingdom
end

---@public [Debug]
function RoleBaseClass:PrintRole() -- const
    return string.format('{Role:%s:%i}', self:GetRoleId(), self:RoleName())
end

return