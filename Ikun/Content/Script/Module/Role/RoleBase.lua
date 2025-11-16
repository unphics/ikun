
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
---@field private _RoleId number
---@field private _RoleCfgId number
---@field private _RoleName string
---@field private _BelongKingdom Kingdom 所属国家
local RoleBaseClass = class.class'RoleBaseClass' {
    RoleTick = function()end,
    LateAtNight = function()end,
    GetRoleId = function()end,
    GetRoleCfgId = function()end,
    RoleName = function()end,
    GetBelongKingdom = function()end,
    PrintRole = function()end,
    Avatar = nil,
    Bag = nil,
    QuestComp = nil,
    QuestGiver = nil,
    NpcChat = nil,
    HoldLocation = nil,
    _BelongKingdom = nil,
    _RoleId = -1,
    _RoleCfgId = -1,
    _RoleName = '未命名',
}

---@public
function RoleBaseClass:ctor()
    self.Bag = class.new'BagClass'(self)
    self.QuestComp = class.new 'QuestCompClass'(self)
    self.QuestGiver = class.new 'QuestGiverClass'(self)
    self.Bag = class.new 'BagClass'(self)
    self.NpcChat = class.new 'NpcChatClass'(self)
end

---@public
---@param DeltaTime number
function RoleBaseClass:RoleTick(DeltaTime)
    if self.Agent then
        self.Agent:TickAgent(DeltaTime)
    end
end

---@public
function RoleBaseClass:InitRole(ConfigId)
    local config = RoleMgr:GetRoleConfig(ConfigId) ---@type RoleConfig
    if not config then
        return log.error(log.key.roleinit,'无效的配置Id')
    end

    self._RoleCfgId = ConfigId
    self._RoleName = config.RoleName

    self.HoldLocation = class.new 'RoleHoldLocationClass'(self, ConfigId)
    
    local DistrictMgr = Cosmos:GetStar().DistrictMgr ---@type DistrictMgr
    self.BelongKingdomLua = DistrictMgr:FindKingdomByCfgId(config.BelongKingdom) ---@type Kingdom
    self.BelongKingdomLua:AddKingdomMember(self)
    
    self.HoldLocation = class.new 'RoleHoldLocationClass'(self, ConfigId)

    -- todo
    -- self.Avatar.SkillComp:InitRoleSkill()
    
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
end

---@public [Pure]
---@return number
function RoleBaseClass:GetRoleId()
    return self._RoleId
end

---@public [Pure]
---@return number
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