
---
---@brief   角色的基类
---@author  zys
---@data    Sun Nov 09 2025 09:27:37 GMT+0800 (中国标准时间)
---

local NpcChat = require("Content/Chat/NpcChat")
require('Module/Role/RoleHoldLocation')

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

    if config.GoapKey then
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

---@public [Pure]
---@return integer
function RoleBaseClass:GetRoleId()
    return self._RoleId
end

---@public [Pure]
---@return integer
function RoleBaseClass:GetRoleCfgId()
    return self._RoleCfgId
end

---@public [Pure]
---@return string
function RoleBaseClass:RoleName()
    return self._RoleName
end

---@public [Pure]
---@return Kingdom
function RoleBaseClass:GetBelongKingdom()
    return self._BelongKingdom
end

---@public [Pure] [Debug]
function RoleBaseClass:PrintRole()
    return string.format('{Role:%s:%i}', self:GetRoleId(), self:RoleName())
end

return